package idv.cjcat.stardustextended.fields;

import openfl.geom.Point;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Radial field.
 */
class RadialField extends Field {
	/**
	 * The X coordinate of the center of the field.
	 */
	public var x:Float;

	/**
	 * The Y coordinate of the center of the field.
	 */
	public var y:Float;

	/**
	 * The strength of the field.
	 */
	public var strength:Float;

	/**
	 * The attenuation power of the field, in powers per pixel.
	 */
	public var attenuationPower:Float;

	/**
	 * If a point is closer to the center than this value,
	 * it's treated as if it's this far from the center.
	 * This is to prevent simulation from blowing up for points too near to the center.
	 */
	public var epsilon:Float;

	public function new(x:Float = 0, y:Float = 0, strength:Float = 1, attenuationPower:Float = 0, epsilon:Float = 1) {
		super();
		this.x = x;
		this.y = y;
		this.strength = strength;
		this.attenuationPower = attenuationPower;
		this.epsilon = epsilon;
	}

	private var _rVec:Vec2D = new Vec2D(0, 0);
	private var _calLen:Float;

	inline final override private function calculateMotionData2D(particle:Particle):MotionData2D {
		_rVec.x = particle.x - x;
		_rVec.y = particle.y - y;

		_calLen = _rVec.length;

		if (_calLen < epsilon) {
			_calLen = epsilon;
		}

		_rVec.length = strength * Math.pow(_calLen, -0.5 * attenuationPower);

		return MotionData2DPool.get(_rVec.x, _rVec.y);
	}

	override public function setPosition(xc:Float, yc:Float):Void {
		x = xc;
		y = yc;
	}

	override public function getPosition():Point {
		position.setTo(x, y);
		return position;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "RadialField";
	}

	override public function toXML():Xml {
		var xml:Xml = cast super.toXML();

		xml.set("x", Std.string(x));
		xml.set("y", Std.string(y));
		xml.set("strength", Std.string(strength));
		xml.set("attenuationPower", Std.string(attenuationPower));
		xml.set("epsilon", Std.string(epsilon));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("x")) {
			x = Std.parseFloat(xml.get("x"));
		}
		if (xml.exists("y")) {
			y = Std.parseFloat(xml.get("y"));
		}
		if (xml.exists("strength")) {
			strength = Std.parseFloat(xml.get("strength"));
		}
		if (xml.exists("attenuationPower")) {
			attenuationPower = Std.parseFloat(xml.get("attenuationPower"));
		}
		if (xml.exists("epsilon")) {
			epsilon = Std.parseFloat(xml.get("epsilon"));
		}
	}
}
