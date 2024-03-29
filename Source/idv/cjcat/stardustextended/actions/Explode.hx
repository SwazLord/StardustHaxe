package idv.cjcat.stardustextended.actions;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;

/**
 * Creates a shock wave that spreads out from a single point, applying acceleration to particles along the way of propagation.
 */
class Explode extends Action {
	/**
	 * The X coordinate of the center.
	 */
	public var x:Float;

	/**
	 * The Y coordinate of the center.
	 */
	public var y:Float;

	/**
	 * The strength of the shockwave.
	 */
	public var strength:Float;

	/**
	 * The speed of shockwave propogation, in pixels per emitter step.
	 */
	public var growSpeed:Float;

	/**
	 * The shockwave would not affect particles beyond this distance.
	 */
	public var maxDistance:Float;

	/**
	 * The attenuation power of the shockwave, in powers per pixel.
	 */
	public var attenuationPower:Float;

	/**
	 * If a particle is closer to the center than this value, it's treated as if it's this distance away from the center.
	 * This is to prevent the simulation to blow up for particles too close to the center.
	 */
	public var epsilon:Float;

	/**
	 * True is its not in the middle of an explosion
	 */
	public var discharged:Bool;

	private var _currentInnerRadius:Float;
	private var _currentOuterRadius:Float;

	public function new(x:Float = 0, y:Float = 0, strength:Float = 5, growSpeed:Float = 40, maxDistance:Float = 200, attenuationPower:Float = 0.1,
			epsilon:Float = 1) {
		super();
		this.x = x;
		this.y = y;
		this.strength = strength;
		this.growSpeed = growSpeed;
		this.maxDistance = maxDistance;
		this.attenuationPower = attenuationPower;
		this.epsilon = epsilon;

		discharged = true;
	}

	/**
	 * Causes a shockwave to spread out from the center.
	 */
	public function explode():Void {
		discharged = false;
		_currentInnerRadius = 0;
		_currentOuterRadius = growSpeed;
	}

	override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		if (discharged) {
			return;
		}

		var r:Vec2D = Vec2DPool.get(particle.x - x, particle.y - y);
		var len:Float = r.length;
		if (len < epsilon) {
			len = epsilon;
		}
		if ((len >= _currentInnerRadius) && (len < _currentOuterRadius)) {
			r.length = strength * Math.pow(len, -attenuationPower);
			particle.vx += r.x * timeDelta;
			particle.vy += r.y * timeDelta;
		}

		Vec2DPool.recycle(r);
	}

	inline final override public function postUpdate(emitter:Emitter, time:Float):Void {
		if (discharged) {
			return;
		}

		_currentInnerRadius += growSpeed;
		_currentOuterRadius += growSpeed;
		if (_currentInnerRadius > maxDistance) {
			discharged = true;
		}
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "Explode";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("x", Std.string(x));
		xml.set("y", Std.string(y));
		xml.set("strength", Std.string(strength));
		xml.set("growSpeed", Std.string(growSpeed));
		xml.set("maxDistance", Std.string(maxDistance));
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
		if (xml.exists("growSpeed")) {
			growSpeed = Std.parseFloat(xml.get("growSpeed"));
		}
		if (xml.exists("maxDistance")) {
			maxDistance = Std.parseFloat(xml.get("maxDistance"));
		}
		if (xml.exists("attenuationPower")) {
			attenuationPower = Std.parseFloat(xml.get("attenuationPower"));
		}
		if (xml.exists("epsilon")) {
			epsilon = Std.parseFloat(xml.get("epsilon"));
		}
	}
}
