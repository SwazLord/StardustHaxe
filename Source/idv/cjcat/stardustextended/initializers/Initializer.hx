package idv.cjcat.stardustextended.initializers;

import openfl.Vector;
import openfl.events.EventDispatcher;
import haxe.Constraints.Function;
import idv.cjcat.stardustextended.events.StardustInitializerEvent;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * An initializer is used to alter just once (i.e. initialize) a particle's properties upon the particle's birth.
 *
 * <p>
 * An initializer can be associated with an emitter or a particle factory.
 * </p>
 *
 * <p>
 * Default priority = 0;
 * </p>
 */
@:meta(Event(name = "PRIORITY_CHANGE", type = "idv.cjcat.stardustextended.events.StardustInitializerEvent"))
@:meta(Event(name = "ADD", type = "idv.cjcat.stardustextended.events.StardustInitializerEvent"))
@:meta(Event(name = "REMOVE", type = "idv.cjcat.stardustextended.events.StardustInitializerEvent"))
class Initializer extends StardustElement {
	private var _priority:Int;

	public var priority(get, set):Int;

	private var eventDispatcher(default, never):EventDispatcher = new EventDispatcher();

	private static var addEvent:StardustInitializerEvent = new StardustInitializerEvent(StardustInitializerEvent.ADD);
	private static var removeEvent:StardustInitializerEvent = new StardustInitializerEvent(StardustInitializerEvent.REMOVE);
	private static var priorityChangeEvent:StardustInitializerEvent = new StardustInitializerEvent(StardustInitializerEvent.PRIORITY_CHANGE);

	public function addEventListener(_type:String, listener:Dynamic, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void {
		eventDispatcher.addEventListener(_type, listener, useCapture, priority, useWeakReference);
	}

	public function removeEventListener(_type:String, listener:Dynamic, useCapture:Bool = false):Void {
		eventDispatcher.removeEventListener(_type, listener, useCapture);
	}

	public function dispatchAddEvent():Void {
		eventDispatcher.dispatchEvent(addEvent);
	}

	public function dispatchRemoveEvent():Void {
		eventDispatcher.dispatchEvent(removeEvent);
	}

	/**
	 * Denotes if the initializer is active, true by default.
	 */
	public var active:Bool;

	public function new() {
		super();
		priority = 0;
		active = true;

		addEvent.initializer = this;
		removeEvent.initializer = this;
		priorityChangeEvent.initializer = this;
	}

	/** @private */
	public function doInitialize(particles:Vector<Particle>, currentTime:Float):Void {
		if (active) {
			var particle:Particle;
			for (m in 0...particles.length) {
				particle = particles[m];
				initialize(particle);
			}
		}
	}

	/**
	 * [Template Method] This is the method that alters a particle's properties.
	 *
	 * <p>
	 * Override this property to create custom initializers.
	 * </p>
	 * @param    particle
	 */
	public function initialize(particle:Particle):Void { // abstract method
	}

	/**
	 * Initializers will be sorted according to their priorities.
	 *
	 * <p>
	 * This is important,
	 * since some initializers may rely on other initializers to perform initialization beforehand.
	 * You can alter the priority of an initializer, but it is recommended that you use the default values.
	 * </p>
	 */
	private function get_priority():Int {
		return _priority;
	}

	private function set_priority(value:Int):Int {
		_priority = value;
		eventDispatcher.dispatchEvent(priorityChangeEvent);
		return value;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "Initializer";
	}

	override public function getElementTypeXMLTag():Xml {
		return Xml.parse("<initializers/>");
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();
		xml.set("active", Std.string(active));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);
		if (xml.exists("active")) {
			active = (xml.get("active") == "true");
		}
	}
}
