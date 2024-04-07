package idv.cjcat.stardustextended.actions;

import openfl.Vector;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Applies random acceleration to particles.
 *
 * <p>
 * Default priority = -3
 * </p>
 */
class RandomDrift extends Action {
	public var randomX(never, set):Random;
	public var randomY(never, set):Random;
	public var maxX(get, set):Float;
	public var maxY(get, set):Float;

	/**
	 * Whether the particles acceleration is divided by their masses before applied to them, true by default.
	 * When set to true, it simulates a gravity that applies equal acceleration on all particles.
	 */
	public var massless:Bool;

	private var _maxX:Float;
	private var _maxY:Float;
	private var _randomX:Random;
	private var _randomY:Random;
	private var _timeDeltaOneSec:Float;

	public function new(maxX:Float = 10, maxY:Float = 10, randomX:Random = null, randomY:Random = null) {
		super();
		priority = -3;

		this.massless = true;
		this.randomX = randomX;
		this.randomY = randomY;
		this.maxX = maxX;
		this.maxY = maxY;
	}

	/**
	 * The random object used to generate a random number for the acceleration's x component in the range [-maxX, maxX], uniform random by default.
	 * You don't have to set the random object's range. The range is automatically set each time before the random generation.
	 */
	inline final private function set_randomX(value:Random):Random {
		if (value == null) {
			value = new UniformRandom();
		}
		_randomX = value;
		return value;
	}

	/**
	 * The random object used to generate a random number for the acceleration's y component in the range [-maxX, maxX], uniform random by default.
	 * You don't have to set the ranodm object's range. The range is automatically set each time before the random generation.
	 */
	inline final private function set_randomY(value:Random):Random {
		if (value == null) {
			value = new UniformRandom();
		}
		_randomY = value;
		return value;
	}

	/**
	 * The acceleration's x component ranges from -maxX to maxX.
	 */
	inline final private function get_maxX():Float {
		return _maxX;
	}

	inline final private function set_maxX(value:Float):Float {
		_maxX = value;
		_randomX.setRange(-_maxX, _maxX);
		return value;
	}

	/**
	 * The acceleration's y component ranges from -maxY to maxY.
	 */
	inline final private function get_maxY():Float {
		return _maxY;
	}

	inline final private function set_maxY(value:Float):Float {
		_maxY = value;
		_randomY.setRange(-_maxY, _maxY);
		return value;
	}

	override public function preUpdate(emitter:Emitter, time:Float):Void {
		_timeDeltaOneSec = time * 60;
	}

	private var _updateRX:Float;
	private var _updateRY:Float;

	private var _updateFactor:Float;

	override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		_updateRX = _randomX.random();
		_updateRY = _randomY.random();

		if (!massless) {
			_updateFactor = 1 / particle.mass;
			_updateRX *= _updateFactor;
			_updateRY *= _updateFactor;
		}

		particle.vx += _updateRX * _timeDeltaOneSec;
		particle.vy += _updateRY * _timeDeltaOneSec;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getRelatedObjects():Vector<StardustElement> {
		// return [_randomX, _randomY];
		return new Vector<StardustElement>([_randomX, _randomY]);
	}

	override public function getXMLTagName():String {
		return "RandomDrift";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("massless", Std.string(massless));
		xml.set("maxX", Std.string(_maxX));
		xml.set("maxY", Std.string(_maxY));
		xml.set("randomX", Std.string(_randomX.name));
		xml.set("randomY", Std.string(_randomY.name));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("massless")) {
			massless = (xml.get("massless") == "true");
		}
		if (xml.exists("maxX")) {
			_maxX = Std.parseFloat(xml.get("maxX"));
		}
		if (xml.exists("maxY")) {
			_maxY = Std.parseFloat(xml.get("maxY"));
		}
		if (xml.exists("randomX")) {
			randomX = try cast(builder.getElementByName(xml.get("randomX")), Random) catch (e:Dynamic) null;
		}
		if (xml.exists("randomY")) {
			randomY = try cast(builder.getElementByName(xml.get("randomY")), Random) catch (e:Dynamic) null;
		}
	}
}
