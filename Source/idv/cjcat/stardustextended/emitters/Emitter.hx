package idv.cjcat.stardustextended.emitters;

import openfl.utils.Function;
import openfl.Vector;
import openfl.events.EventDispatcher;
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
@:events(StardustEmitterStepEndEvent.TYPE => "eventDispatcher")
class Emitter extends StardustElement implements ActionCollector implements InitializerCollector {
	private var eventDispatcher:EventDispatcher = new EventDispatcher();

	public function addEventListener(_type:String, listener:Dynamic, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void {
		eventDispatcher.addEventListener(_type, listener, useCapture, priority, useWeakReference);
	}

	public function removeEventListener(_type:String, listener:Dynamic, useCapture:Bool = false):Void {
		eventDispatcher.removeEventListener(_type, listener, useCapture);
	}

	private var newParticles:Vector<Particle> = new Vector<Particle>();
	private var _particles:Vector<Particle> = new Vector<Particle>();

	public var particles(get, never):Vector<Particle>;

	/**
	 * Returns every managed particle for custom parameter manipulation.
	 * The returned Vector is not a copy.
	 * @return
	 */
	@:keep
	inline public final function get_particles():Vector<Particle> {
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
	private var _actionCollection:ActionCollection = new ActionCollection();
	private var activeActions:Vector<Action> = new Vector<Action>();
	private var _invFps:Float = 1 / 60 - timeStepCorrectionOffset;
	private var timeSinceLastStep:Float = 0;
	private var _fps:Float;

	private var _numParticles:Int;

	public var numParticles(get, never):Int;
	public var actions(get, never):Vector<Action>;
	public var initializers(get, never):Vector<Initializer>;

	public function new(clock:Clock = null, particleHandler:ParticleHandler = null) {
		super();
		this.clock = clock;
		this.active = true;
		this.particleHandler = particleHandler;
		fps = 60;
	}

	/**
	 * The clock determines how many particles the emitter creates in each step.
	 */
	public var clock(get, set):Clock;

	private function get_clock():Clock {
		return _clock;
	}

	private function set_clock(value:Clock):Clock {
		if (value == null)
			value = new SteadyClock(0);
		_clock = value;
		return value;
	}

	/**
	 * Sets the frame rate of the simulation. Lower framerates consume less CPU, but make your animations
	 * look choppy. Note that the simulation behaves slightly differently at different FPS settings
	 * (e.g. A clock produces the same amount of ticks on all FPSes, but it does it at a different times,
	 * resulting in particles emitted in batches instead smoothly)
	 */
	public var fps(get, set):Float;

	private function set_fps(val:Float):Float {
		if (val > 60) {
			val = 60;
		}
		_fps = val;
		_invFps = 1 / val - timeStepCorrectionOffset;
		return val;
	}

	private function get_fps():Float {
		return _fps;
	}

	// main loop
	// ------------------------------------------------------------------------------------------------

	/**
	 * This method is the main simulation loop of the emitter.
	 *
	 * <p>
	 * In order to keep the simulation go on, this method should be called continuously.
	 * It is recommended that you call this method through the <code>Event.ENTER_FRAME</code> event or the <code>TimerEvent.TIMER</code> event.
	 * </p>
	 * @param time The time elapsed since the last step in seconds
	 */
	@:keep
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

		for (i in 0...len) {
			action = actions[i];

			if (action.active) {
				activeActions.push(action);
			}
		}

		// sorting
		len = activeActions.length;

		for (i in 0...len) {
			action = activeActions[i];

			if (action.needsSortedParticles) {
				_particles.sort(Particle.compareFunction);
				break;
			}
		}

		// invoke action preupdates.
		for (i in 0...len) {
			activeActions[i].preUpdate(this, timeSinceLastStep);
		}

		// update the remaining particles
		var p:Particle;
		var m:Int = 0;

		while (m < _particles.length) {
			p = _particles[m];

			for (i in 0...len) {
				action = activeActions[i];
				// update particle
				action.update(this, p, timeSinceLastStep, currentTime);
			}

			if (p.isDead) {
				particleHandler.particleRemoved(p);
				p.destroy();
				factory.recycle(p);
				_particles.splice(m, 1);
			} else {
				m++;
			}
		}

		// postUpdate
		for (i in 0...len) {
			activeActions[i].postUpdate(this, timeSinceLastStep);
		}

		if (eventDispatcher.hasEventListener(StardustEmitterStepEndEvent.TYPE)) {
			eventDispatcher.dispatchEvent(new StardustEmitterStepEndEvent(this));
		}

		particleHandler.stepEnd(this, _particles, timeSinceLastStep);

		timeSinceLastStep = 0;
	}

	// ------------------------------------------------------------------------------------------------
	// end of main loop
	// actions & initializers
	// ------------------------------------------------------------------------------------------------

	/**
	 * Returns every action for this emitter
	 */
	@:keep @:inline public final function get_actions():Vector<Action> {
		return _actionCollection.actions;
	}

	/**
	 * Adds an action to the emitter.
	 * @param action
	 */
	public function addAction(action:Action):Void {
		_actionCollection.addAction(action);
		action.dispatchAddEvent();
	}

	/**
	 * Removes an action from the emitter.
	 * @param action
	 */
	public final function removeAction(action:Action):Void {
		_actionCollection.removeAction(action);
		action.dispatchRemoveEvent();
	}

	/**
	 * Removes all actions from the emitter.
	 */
	public final function clearActions():Void {
		var actions:Vector<Action> = _actionCollection.actions;
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
	public final function get_initializers():Vector<Initializer> {
		return factory.initializerCollection.initializers;
	}

	/**
	 * Adds an initializer to the emitter.
	 * @param initializer
	 */
	public function addInitializer(initializer:Initializer):Void {
		factory.addInitializer(initializer);
		initializer.dispatchAddEvent();
	}

	/**
	 * Removes an initializer form the emitter.
	 * @param initializer
	 */
	public final function removeInitializer(initializer:Initializer):Void {
		factory.removeInitializer(initializer);
		initializer.dispatchRemoveEvent();
	}

	/**
	 * Removes all initializers from the emitter.
	 */
	public final function clearInitializers():Void {
		var initializers:Vector<Initializer> = factory.initializerCollection.initializers;
		var len:Int = initializers.length;
		for (i in 0...len) {
			initializers[i].dispatchRemoveEvent();
		}
		factory.clearInitializers();
	}

	// ------------------------------------------------------------------------------------------------
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
	// ------------------------------------------------------------------------------------------------

	/**
	 * The number of particles in the emitter.
	 */
	public final function get_numParticles():Int {
		return _particles.length;
	}

	/**
	 * This method is called by the emitter to create new particles.
	 */
	@:keep @:inline public final function createParticles(pCount:UInt):Vector<Particle> {
		newParticles.length = 0;
		factory.createParticles(pCount, currentTime, newParticles);
		addParticles(newParticles);
		return newParticles;
	}

	/**
	 * This method is used to manually add existing particles to the emitter's simulation.
	 * Note: you have to initialize the particles manually! To call all initializers in this emitter for the
	 * particle call <code>createParticles</code> instead.
	 * @param particles
	 */
	@:keep @:inline public final function addParticles(particles:Vector<Particle>):Void {
		var particle:Particle;
		var plen:UInt = particles.length;

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

		_particles = new Vector<Particle>();
	}

	// ------------------------------------------------------------------------------------------------
	// end of particles
	// XML
	// ------------------------------------------------------------------------------------------------

	override public function getRelatedObjects():Vector<StardustElement> {
		var allElems:Vector<StardustElement> = new Vector<StardustElement>();
		allElems.push(_clock);
		allElems.push(particleHandler);
		allElems = allElems.concat(cast initializers);
		allElems = allElems.concat(cast actions);
		return allElems;
	}

	override public function getXMLTagName():String {
		return "Emitter2D";
	}

	override public function getElementTypeXMLTag():Xml {
		return Xml.createElement("emitters");
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();
		xml.set("active", Std.string(active));
		xml.set("clock", _clock.name);
		xml.set("particleHandler", particleHandler.name);
		xml.set("fps", Std.string(fps));

		if (actions.length > 0) {
			xml.addChild(Xml.createElement("actions"));
			for (action in actions) {
				xml.elementsNamed("actions").next().addChild(action.getXMLTag());
			}
		}

		if (initializers.length > 0) {
			xml.addChild(Xml.createElement("initializers"));
			for (initializer in initializers) {
				xml.elementsNamed("initializers").next().addChild(initializer.getXMLTag());
			}
		}

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		_actionCollection.clearActions();
		factory.clearInitializers();

		if (xml.exists("active"))
			active = xml.get("active") == "true";
		if (xml.exists("clock"))
			clock = cast builder.getElementByName(xml.get("clock"));
		if (xml.exists("particleHandler"))
			particleHandler = cast builder.getElementByName(xml.get("particleHandler"));
		if (xml.exists("fps"))
			fps = Std.parseFloat(xml.get("fps"));

		var node:Xml;
		for (node in xml.elementsNamed("actions")) {
			for (childNode in node.elements()) {
				addAction(cast builder.getElementByName(childNode.get("name")));
			}
		}
		for (node in xml.elementsNamed("initializers")) {
			for (childNode in node.elements()) {
				addInitializer(cast builder.getElementByName(childNode.get("name")));
			}
		}
	}

	// ------------------------------------------------------------------------------------------------
	// end of XML
}
