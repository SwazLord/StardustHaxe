package idv.cjcat.stardustextended.actions;

import openfl.Vector;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Applies acceleration normal to a particle's velocity to the particle.
 */
class NormalDrift extends Action {
	public var max(get, set):Float;
	public var random(get, set):Random;

	/**
	 * Whether the particles acceleration is divided by their masses before applied to them, true by default.
	 * When set to true, it simulates a gravity that applies equal acceleration on all particles.
	 */
	public var massless:Bool;

	private var _timeDeltaOneSec:Float;
	private var _random:Random;
	private var _max:Float;

	public function new(max:Float = 1, random:Random = null) {
		super();
		this.massless = true;
		this.random = random;
		this.max = max;
	}

	/**
	 * The acceleration ranges from -max to max.
	 */
	private function get_max():Float {
		return _max;
	}

	private function set_max(value:Float):Float {
		_max = value;
		if (_random != null && !Math.isNaN(value)) {
			_random.setRange(-_max, _max);
		}
		return value;
	}

	/**
	 * The random object used to generate a random number for the acceleration in the range [-max, max], uniform random by default.
	 * You don't have to set the random object's range. The range is automatically set each time before the random generation.
	 */
	private function get_random():Random {
		return _random;
	}

	private function set_random(value:Random):Random {
		if (value == null) {
			value = new UniformRandom();
		}
		_random = value;
		if (!Math.isNaN(_max)) {
			_random.setRange(-_max, _max);
		}
		return value;
	}

	override public function preUpdate(emitter:Emitter, time:Float):Void {
		_timeDeltaOneSec = time * 60;
	}

	private var _updateVec:Vec2D = new Vec2D(0, 0);

	inline final override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		_updateVec.x = particle.vy;
		_updateVec.y = particle.vx;

		_updateVec.length = _random.random();

		if (!massless) {
			_updateVec.length /= particle.mass;
		}

		particle.vx += _updateVec.x * _timeDeltaOneSec;
		particle.vy += _updateVec.y * _timeDeltaOneSec;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getRelatedObjects():Vector<StardustElement> {
		// return [_random];
		return new Vector<StardustElement>([_random]);
	}

	override public function getXMLTagName():String {
		return "NormalDrift";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("massless", Std.string(massless));
		xml.set("max", Std.string(_max));
		xml.set("random", Std.string(_random.name));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("massless")) {
			massless = (xml.get("massless") == "true");
		}
		if (xml.exists("max")) {
			max = Std.parseFloat(xml.get("max"));
		}
		if (xml.exists("random")) {
			random = try cast(builder.getElementByName(xml.get("random")), Random) catch (e:Dynamic) null;
		}
	}
}
