package idv.cjcat.stardustextended.clocks;

import openfl.Vector;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * This clock can be used to create randomized impulses and has more parameters than ImpulseClock
 */
class ImpulseClock extends Clock {
	public var initialDelay(get, set):Random;
	public var impulseLength(get, set):Random;
	public var impulseInterval(get, set):Random;

	private var _impulseInterval:Random;

	/**
	 * How many particles to create when an impulse is happening.
	 */
	public var ticksPerCall:Float;

	private var _initialDelay:Random;
	private var currentImpulseInterval:Float;
	private var currentImpulseLength:Float;
	private var currentInitialDelay:Float;
	private var _impulseLength:Random;
	private var currentTime:Float;

	/**
	 * The delay in seconds until the first impulse happens
	 */
	private function set_initialDelay(value:Random):Random {
		_initialDelay = value;
		setCurrentInitialDelay();
		return value;
	}

	private function get_initialDelay():Random {
		return _initialDelay;
	}

	/**
	 * The length of a impulses in seconds.
	 */
	private function set_impulseLength(value:Random):Random {
		_impulseLength = value;
		setCurrentImpulseLength();
		return value;
	}

	private function get_impulseLength():Random {
		return _impulseLength;
	}

	/**
	 * The time between a impulses in seconds.
	 */
	private function set_impulseInterval(value:Random):Random {
		_impulseInterval = value;
		setCurrentImpulseInterval();
		return value;
	}

	private function get_impulseInterval():Random {
		return _impulseInterval;
	}

	public function new(_impulseInterval:Random = null, _impulseLength:Random = null, _initialDelay:Random = null, _ticksPerCall:Float = 1) {
		super();
		impulseInterval = (_impulseInterval != null) ? _impulseInterval : new UniformRandom(20, 10);
		impulseLength = (_impulseLength != null) ? _impulseLength : new UniformRandom(5, 0);
		initialDelay = (_initialDelay != null) ? _initialDelay : new UniformRandom(0, 0);
		ticksPerCall = _ticksPerCall;
		currentTime = 0;
	}

	override public final function getTicks(time:Float):Int {
		var ticks:Int = 0;
		currentInitialDelay -= time;
		if (currentInitialDelay < 0) {
			currentTime += time;
			if (currentTime <= currentImpulseLength) {
				ticks = Std.int(StardustMath.randomFloor(ticksPerCall * time));
			} else if (currentTime - time <= currentImpulseLength) {
				// timestep was too big and it overstepped this impulse. Calculate the ticks for the fraction time
				ticks = Std.int(StardustMath.randomFloor(ticksPerCall * (currentImpulseLength - currentTime + time)));
			}
			if (currentTime >= currentImpulseInterval) {
				setCurrentImpulseLength();
				setCurrentImpulseInterval();
				currentTime = 0;
			}
		}
		return ticks;
	}

	/**
	 * The emitter step after the <code>impulse()</code> call creates a burst of particles.
	 */
	public function impulse():Void {
		currentInitialDelay = -1;
		currentTime = 0;
	}

	inline final private function setCurrentImpulseLength():Void {
		var len:Float = _impulseLength.random();
		currentImpulseLength = (len > 0) ? len : 0;
	}

	inline final private function setCurrentImpulseInterval():Void {
		var val:Float = _impulseInterval.random();
		currentImpulseInterval = (val > 0) ? val : 0;
	}

	inline final private function setCurrentInitialDelay():Void {
		var val:Float = _initialDelay.random();
		currentInitialDelay = (val > 0) ? val : 0;
	}

	/**
	 * Resets the clock and randomizes all values
	 */
	override public function reset():Void {
		setCurrentInitialDelay();
		setCurrentImpulseLength();
		setCurrentImpulseInterval();
		currentTime = 0;
	}

	// Xml
	//------------------------------------------------------------------------------------------------
	override public function getRelatedObjects():Vector<StardustElement> {
		return new Vector<StardustElement>([_impulseInterval, _impulseLength, _initialDelay]);
	}

	override public function getXMLTagName():String {
		return "ImpulseClock";
	}

	override public function toXML():Xml {
		var xml:Xml = cast super.toXML();
		xml.set("ticksPerCall", Std.string(ticksPerCall));
		xml.set("impulseInterval", _impulseInterval.name);
		xml.set("impulseLength", _impulseLength.name);
		xml.set("initialDelay", _initialDelay.name);
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		// The randoms its using might not be initialized yet
		if (xml.exists("ticksPerCall"))
			ticksPerCall = Std.parseFloat(xml.get("ticksPerCall"));
		if (xml.exists("impulseLength"))
			_impulseLength = cast builder.getElementByName(xml.get("impulseLength"));
		if (xml.exists("impulseInterval"))
			_impulseInterval = cast builder.getElementByName(xml.get("impulseInterval"));

		if (xml.exists("initialDelay"))
			_initialDelay = cast builder.getElementByName(xml.get("initialDelay"));

		// Legacy names, for simulations created with old versions
		if (xml.exists("impulseCount"))
			ticksPerCall = Std.parseFloat(xml.get("impulseCount"));
		if (xml.exists("repeatCount"))
			_impulseLength = new UniformRandom(Std.parseInt(xml.get("repeatCount")), 0);
		if (xml.exists("burstInterval"))
			_impulseInterval = new UniformRandom(Std.parseInt(xml.get("burstInterval")), 0);
	}

	override public function onXMLInitComplete():Void {
		reset();
	}
}
