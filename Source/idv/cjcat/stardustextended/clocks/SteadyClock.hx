package idv.cjcat.stardustextended.clocks;

import openfl.Vector;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Causes the emitter to create particles at a steady rate.
 */
class SteadyClock extends Clock {
	public var initialDelay(get, set):Random;

	/**
	 * How many particles to create in each second.
	 *
	 * If less than one, it's the probability of an emitter to create a single particle in each second.
	 */
	public var ticksPerCall:Float;

	/**
	 * The delay in seconds until the the clock starts
	 */
	private function set_initialDelay(value:Random):Random {
		_initialDelay = value;
		setCurrentInitialDelay();
		return value;
	}

	private function get_initialDelay():Random {
		return _initialDelay;
	}

	private var _initialDelay:Random;
	private var currentInitialDelay:Float;
	private var currentTime:Float;

	public function new(ticksPerCall:Float = 1, _initialDelay:Random = null) {
		super();
		this.ticksPerCall = ticksPerCall;
		initialDelay = (_initialDelay != null) ? _initialDelay : new UniformRandom(0, 0);
		currentTime = 0;
	}

	inline final override public function getTicks(time:Float):Int {
		currentTime = currentTime + time;

		if (currentTime > currentInitialDelay) {
			return StardustMath.randomFloor(ticksPerCall * time);
		}

		return 0;
	}

	/**
	 * Resets the clock and randomizes all values
	 */
	override public function reset():Void {
		currentTime = 0;
		setCurrentInitialDelay();
	}

	inline final private function setCurrentInitialDelay():Void {
		var val:Float = _initialDelay.random();
		currentInitialDelay = (val > 0) ? val : 0;
	}

	// Xml
	//------------------------------------------------------------------------------------------------
	override public function getXMLTagName():String {
		return "SteadyClock";
	}

	override public function getRelatedObjects():Vector<StardustElement> {
		
		return new Vector<StardustElement>([_initialDelay]);
	}

	override public function toXML():Xml {
		var xml:Xml = cast super.toXML();

		xml.set("ticksPerCall", Std.string(ticksPerCall));
		xml.set("initialDelay", _initialDelay.name);

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		ticksPerCall = Std.parseFloat(xml.get("ticksPerCall"));

		if (xml.exists("initialDelay")) {
			_initialDelay = try cast(builder.getElementByName(xml.get("initialDelay")), Random) catch (e:Dynamic) null;
		}
	}

	override public function onXMLInitComplete():Void {
		setCurrentInitialDelay();
	}
}
