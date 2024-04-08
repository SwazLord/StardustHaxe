package idv.cjcat.stardustextended.actions;

import flash.events.EventDispatcher;
import haxe.rtti.Meta;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.events.StardustActionEvent;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * An action is used to continuously update a particle's property.
 *
 * <p>
 * An action is associated with an emitter. On each <code>Emitter.step()</code> method call,
 * the action's <code>update()</code> method is called with each particles in the emitter passed in as parameter.
 * This method updates a particles property, such as changing the particle's position according to its velocity,
 * or modifying the particle's velocity based on gravity fields.
 * </p>
 *
 * <p>
 * Default priority = 0;
 * </p>
 */
@:events([
	StardustActionEvent.PRIORITY_CHANGE => "priorityChangeEvent",
	StardustActionEvent.ADD => "addEvent",
	StardustActionEvent.REMOVE => "removeEvent"
])
class Action extends StardustElement {
	private var eventDispatcher:EventDispatcher = new EventDispatcher();

	private static var addEvent:StardustActionEvent = new StardustActionEvent(StardustActionEvent.ADD);
	private static var removeEvent:StardustActionEvent = new StardustActionEvent(StardustActionEvent.REMOVE);
	private static var priorityChangeEvent:StardustActionEvent = new StardustActionEvent(StardustActionEvent.PRIORITY_CHANGE);

	public function addEventListener(_type:String, listener:Dynamic, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void {
		eventDispatcher.addEventListener(_type, listener, useCapture, priority, useWeakReference);
	}

	public function removeEventListener(_type:String, listener:Dynamic, useCapture:Bool = false):Void {
		eventDispatcher.removeEventListener(_type, listener, useCapture);
	}

	@:keep
	inline final public function dispatchAddEvent():Void {
		addEvent.action = this;
		eventDispatcher.dispatchEvent(addEvent);
	}

	@:keep
	inline final public function dispatchRemoveEvent():Void {
		removeEvent.action = this;
		eventDispatcher.dispatchEvent(removeEvent);
	}

	/**
	 * Denotes if the action is active, true by default.
	 */
	public var active:Bool;

	public var _needsSortedParticles:Bool;

	public var needsSortedParticles(get, never):Bool;

	private var _priority:Int;

	public var priority(get, set):Int;

	public function new() {
		super();
		priority = 0;
		active = true;
	}

	/**
	 * [Template Method] This method is called once upon each <code>Emitter.step()</code> method call,
	 * before the <code>update()</code> calls with each particles in the emitter.
	 *
	 * <p>
	 * All setup operations before the <code>update()</code> calls should be done here.
	 * </p>
	 * @param emitter The associated emitter.
	 * @param time The timespan of each emitter's step.
	 */
	public function preUpdate(emitter:Emitter, time:Float):Void {
		// abstract method
	}

	/**
	 * [Template Method] Acts on all particles upon each <code>Emitter.step()</code> method call.
	 *
	 * <p>
	 * Override this method to create custom actions.
	 * </p>
	 * @param emitter The associated emitter.
	 * @param particle The associated particle.
	 * @param timeDelta The timespan of each emitter's step.
	 * @param currentTime The total time from the first emitter.step() call.
	 */
	public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		// abstract method
	}

	/**
	 * [Template Method] This method is called once after each <code>Emitter.step()</code> method call,
	 * after the <code>update()</code> calls with each particles in the emitter.
	 *
	 * <p>
	 * All setup operations after the <code>update()</code> calls should be done here.
	 * </p>
	 * @param emitter The associated emitter.
	 * @param time The timespan of each emitter's step.
	 */
	public function postUpdate(emitter:Emitter, time:Float):Void {
		// abstract method
	}

	/**
	 * Actions will be sorted by the associated emitter according to their priorities.
	 *
	 * <p>
	 * This is important,
	 * since it doesn't make sense to first update a particle's position according to its speed,
	 * and then update the velocity according to gravity fields afterwards.
	 * You can alter the priority of an action, but it is recommended that you use the default values.
	 * </p>
	 */
	@:keep inline final function get_priority():Int {
		return _priority;
	}

	public function set_priority(value:Int):Int {
		_priority = value;

		priorityChangeEvent.action = this;
		eventDispatcher.dispatchEvent(priorityChangeEvent);
		return value;
	}

	/**
	 * Tells the emitter whether this action requires that particles must be sorted before the <code>update()</code> calls.
	 *
	 * <p>
	 * For instance, the <code>Collide</code> action needs all particles to be sorted in X positions.
	 * </p>
	 */
	public function get_needsSortedParticles():Bool {
		return false;
	}

	// XML
	// ------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return Type.getClassName(Type.getClass(this));
	}

	override public function getElementTypeXMLTag():Xml {
		return Xml.createElement("actions");
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();
		xml.set("active", Std.string(active));
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);
		if (xml.exists("active"))
			active = xml.get("active") == "true";
	}

	// ------------------------------------------------------------------------------------------------
	// end of XML
}
