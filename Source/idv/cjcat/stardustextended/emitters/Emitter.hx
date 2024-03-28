package idv.cjcat.stardustextended.emitters;

import idv.cjcat.stardustextended.actions.Action;
import idv.cjcat.stardustextended.actions.ActionCollection;
import idv.cjcat.stardustextended.actions.ActionCollector;
import idv.cjcat.stardustextended.clocks.Clock;
import idv.cjcat.stardustextended.clocks.SteadyClock;
import idv.cjcat.stardustextended.events.StardustEmitterStepEndEvent;
import idv.cjcat.stardustextended.handlers.ParticleHandler;
import idv.cjcat.stardustextended.initializers.Initializer;
import idv.cjcat.stardustextended.initializers.InitializerCollector;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.particles.PooledParticleFactory;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * This class takes charge of the actual particle simulation of the Stardust particle system.
 */
// [Event(name="StardustEmitterStepEndEvent", type="idv.cjcat.stardustextended.events.StardustEmitterStepEndEvent")]
class Emitter extends StardustElement implements ActionCollector implements InitializerCollector {
	private inline static var eventDispatcher:EventDispatcher = new EventDispatcher();

	public function addEventListener(_type:String, listener:Function, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void {
		eventDispatcher.addEventListener(_type, listener, useCapture, priority, useWeakReference);
	}

	public function removeEventListener(_type:String, listener:Function, useCapture:Bool = false):Void {
		eventDispatcher.removeEventListener(_type, listener, useCapture);
	}

	private inline static var newParticles:Array<Particle> = new Array<Particle>();

	private var _particles:Array<Particle> = new Array<Particle>();

	/**
	 * Returns every managed particle for custom parameter manipulation.
	 * The returned Vector is not a copy.
	 * @return
	 */
	// [Inline]
	public var particles(get, never):Array<Particle>;

	inline public final function get_particles():Array<Particle> {
		return _particles;
	}

	/**
	 * Particle handler is used to render particles
	 */
	public var particleHandler:ParticleHandler;

	private var _clock:Clock;

	/**
	 * Whether the emitter is active, true by default.
	 *
	 * <p>
	 * If the emitter is active, it creates particles in each step according to its clock.
	 * Note that even if an emitter is not active, the simulation of existing particles still goes on in each step.
	 * </p>
	 */
	public var active:Bool;

	/**
	 * The time since the simulation is running
	 */
	public var currentTime:Float = 0;

	/**
	 * While the max. fps in Flash is 60, the actual value fluctuates a few ms.
	 * Thus using the real value would cause lots of frame skips
	 * To take this into account Stardust uses internally a slightly smaller value to compensate.
	 */
	public static var timeStepCorrectionOffset:Float = 0.004;

	private var factory:PooledParticleFactory = new PooledParticleFactory();

	private inline static var _actionCollection:ActionCollection = new ActionCollection();
	private inline static var activeActions:Array<Action> = new Array<Action>();

	private var _invFps:Float = 1 / 60 - timeStepCorrectionOffset;
	private var timeSinceLastStep:Float = 0;
	private var _fps:Float;

	public function new(clock:Clock = null, particleHandler:ParticleHandler = null) {
		this.clock = clock;
		this.active = true;
		this.particleHandler = particleHandler;
		fps = 60;
	}

	/**
	 * The clock determines how many particles the emitter creates in each step.
	 */
	public var clock(get, set):Clock;

	public function get_clock():Clock {
		return _clock;
	}

	public function set_clock(value:Clock):Clock {
		if (!value)
			value = new SteadyClock(0);
		_clock = value;

		return _clock;
	}

	/**
	 * Sets the frame rate of the simulation. Lower framerates consume less CPU, but make your animations
	 * look choppy. Note that the simulation behaves slightly differently at different FPS settings
	 * (e.g. A clock produces the same amount of ticks on all FPSes, but it does it at a different times,
	 * resulting in particles emitted in batches instead smoothly)
	 */
	public var fps(get, set):Float;

	public function set_fps(val:Float):Float {
		if (val > 60) {
			val = 60;
		}
		_fps = val;

		_invFps = 1 / val - timeStepCorrectionOffset;
		return _fps;
	}

	public function get_fps():Float {
		return _fps;
	}

	// main loop
	//------------------------------------------------------------------------------------------------

	/**
	 * This method is the main simulation loop of the emitter.
	 *
	 * <p>
	 * In order to keep the simulation go on, this method should be called continuously.
	 * It is recommended that you call this method through the <code>Event.ENTER_FRAME</code> event or the <code>TimerEvent.TIMER</code> event.
	 * </p>
	 * @param time The time elapsed since the last step in seconds
	 */
	// [Inline]
	inline public final function step(time:Float):Void {
		if (time <= 0) {
			return;
		}

		timeSinceLastStep = timeSinceLastStep + time;
		currentTime = currentTime + time;

		if (timeSinceLastStep < _invFps) {
			return;
		}

		// this is not needed when using starling
		// particleHandler.stepBegin(this, _particles, timeSinceLastStep);

		var i:Int;
		var len:Int;

		if (active) {
			createParticles(_clock.getTicks(timeSinceLastStep));
		}

		// filter out active actions
		activeActions.length = 0;
		var action:Action;
		len = actions.length;

		// for (i = 0; i < len; ++i)
		for (i in 0...len) {
			action = actions[i];

			if (action.active) {
				activeActions.push(action);
			}
		}

		// sorting
		len = activeActions.length;

		// for(i = 0; i < len; ++i)
		for (i in 0...len) {
			action = activeActions[i];

			if (action.needsSortedParticles) {
				_particles.sort(Particle.compareFunction);
				break;
			}
		}

		// invoke action preupdates.
		// for (i = 0; i < len; ++i)
		for (i in 0...len) {
			activeActions[i].preUpdate(this, timeSinceLastStep);
		}

		// update the remaining particles
		var p:Particle;

		// for(var m : Int = 0; m < _particles.length; ++m)
		for (m in 0..._particles.length) {
			p = _particles[m];

			// for (i = 0; i < len; ++i)
			for (i in 0...len) {
				action = activeActions[i];
				// update particle
				action.update(this, p, timeSinceLastStep, currentTime);
			}

			if (p.isDead) {
				particleHandler.particleRemoved(p);

				p.destroy();
				factory.recycle(p);

				_particles.removeAt(m);
				m--;
			}
		}

		// postUpdate
		// for(i = 0; i < len; ++i)
		for (i in 0...len) {
			activeActions[i].postUpdate(this, timeSinceLastStep);
		}

		if (eventDispatcher.hasEventListener(StardustEmitterStepEndEvent.TYPE)) {
			eventDispatcher.dispatchEvent(new StardustEmitterStepEndEvent(this));
		}

		particleHandler.stepEnd(this, _particles, timeSinceLastStep);

		timeSinceLastStep = 0;
	}

	//------------------------------------------------------------------------------------------------
	// end of main loop
	// actions & initializers
	//------------------------------------------------------------------------------------------------

	/**
	 * Returns every action for this emitter
	 */
	// [Inline]
	public var actions(get, never):Array<Action>;

	inline public final function get_actions():Array<Action> {
		return _actionCollection.actions;
	}

	/**
	 * Adds an action to the emitter.
	 * @param    action
	 */
	public function addAction(action:Action):Void {
		_actionCollection.addAction(action);
		action.dispatchAddEvent();
	}

	/**
	 * Removes an action from the emitter.
	 * @param    action
	 */
	public final function removeAction(action:Action):Void {
		_actionCollection.removeAction(action);
		action.dispatchRemoveEvent();
	}

	/**
	 * Removes all actions from the emitter.
	 */
	public final function clearActions():Void {
		var actions:Array<Action> = _actionCollection.actions;
		var len:Int = actions.length;
		for (i in 0...len) {
			var action:Action = actions[i];
			action.dispatchRemoveEvent();
		}
		_actionCollection.clearActions();
	}

	/**
	 * Returns all initializers of this emitter.
	 */
	public var initializers(get, never):Array<Initializer>;

	public final function get_initializers():Array<Initializer> {
		return factory.initializerCollection.initializers;
	}

	/**
	 * Adds an initializer to the emitter.
	 * @param    initializer
	 */
	public function addInitializer(initializer:Initializer):Void {
		factory.addInitializer(initializer);
		initializer.dispatchAddEvent();
	}

	/**
	 * Removes an initializer form the emitter.
	 * @param    initializer
	 */
	public final function removeInitializer(initializer:Initializer):Void {
		factory.removeInitializer(initializer);
		initializer.dispatchRemoveEvent();
	}

	/**
	 * Removes all initializers from the emitter.
	 */
	public final function clearInitializers():Void {
		var initializers:Array<Initializer> = factory.initializerCollection.initializers;
		var len:Int = initializers.length;
		for (i in 0...len) {
			initializers[i].dispatchRemoveEvent();
		}
		factory.clearInitializers();
	}

	//------------------------------------------------------------------------------------------------
	// end of actions & initializers

	/**
	 * Resets all properties to their default values and removes all particles.
	 */
	public function reset():Void {
		currentTime = 0;
		clearParticles();
		_clock.reset();
		particleHandler.reset();
	}

	// particles
	//------------------------------------------------------------------------------------------------

	/**
	 * The number of particles in the emitter.
	 */
	public var numParticles(get, never):Int;

	public final function get_numParticles():Int {
		return _particles.length;
	}

	/**
	 * This method is called by the emitter to create new particles.
	 */
	// [Inline]
	public final function createParticles(pCount:UInt):Array<Particle> {
		newParticles.length = 0;
		factory.createParticles(pCount, currentTime, newParticles);
		addParticles(newParticles);
		return newParticles;
	}

	/**
	 * This method is used to manually add existing particles to the emitter's simulation.
	 * Note: you have to initialize the particles manually! To call all initializers in this emitter for the
	 * particle call <code>createParticles</code> instead.
	 * @param    particles
	 */
	// [Inline]
	inline public final function addParticles(particles:Array<Particle>):Void {
		var particle:Particle;

		// const plen:UInt = particles.length;
		var final plen:UInt = particles.length;

		for (m in 0...plen) {
			particle = particles[m];
			_particles.push(particle);

			// handle adding
			particleHandler.particleAdded(particle);
		}
	}

	/**
	 * Clears all particles from the emitter's simulation.
	 */
	public final function clearParticles():Void {
		var particle:Particle;

		for (m in 0..._particles.length) {
			particle = _particles[m];
			// handle removal
			particleHandler.particleRemoved(particle);

			particle.destroy();
			factory.recycle(particle);
		}

		_particles = new Array<Particle>();
	}

	//------------------------------------------------------------------------------------------------
	// end of particles
	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getRelatedObjects():Array<StardustElement> {
		var allElems:Array<StardustElement> = new Array<StardustElement>();
		allElems.push(_clock);
		allElems.push(particleHandler);
		allElems = allElems.concat(initializers);
		allElems = allElems.concat(Array<StardustElement>(actions));
		return allElems;
	}

	override public function getXMLTagName():String {
		return "Emitter2D";
	}

	override public function getElementTypeXMLTag():Xml {
		return <emitters/>;
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();
		xml.att.active = active.toString();
		xml.att.clock = _clock.name;
		xml.att.particleHandler = particleHandler.name;
		xml.att.fps = fps.toString();

		if (actions.length > 0) {
			xml.appendChild(<actions/>);
			for (action in actions) {
				xml.actions.appendChild(action.getXMLTag());
			}
		}

		if (initializers.length > 0) {
			xml.appendChild(<initializers/>);
			for (initializer in initializers) {
				xml.initializers.appendChild(initializer.getXMLTag());
			}
		}

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);
		var access = new haxe.xml.Access(xml);
		_actionCollection.clearActions();
		factory.clearInitializers();

		if (xml.att.active.length())
			active = (xml.att.active == "true");
		if (xml.att.clock.length())
			clock = cast(builder.getElementByName(xml.att.clock), Clock);
		if (xml.att.particleHandler.length())
			particleHandler = cast(builder.getElementByName(xml.att.particleHandler), ParticleHandler);
		if (xml.att.fps.length())
			fps = parseFloat(xml.att.fps);

		var node:Xml;
		for (node in access.node.actions.elements) {
			addAction(cast(builder.getElementByName(node.att.name), Action));
		}
		for (node in access.node.initializers.elements) {
			addInitializer(cast(builder.getElementByName(node.att.name), Initializer));
		}
	}

	//------------------------------------------------------------------------------------------------
	// end of Xml
}
