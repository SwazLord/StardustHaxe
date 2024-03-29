package idv.cjcat.stardustextended.actions;

import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;

/**
 * Causes particles to attract each other.
 *
 * <p>
 * Default priority = -3;
 * </p>
 */
class MutualGravity extends MutualAction {
	/**
	 * The attraction strength multiplier.
	 */
	public var strength:Float;

	/**
	 * If the distance between two particle's is less than this value,
	 * they are processed as if they were apart by distance of this value.
	 * This property is meant to prevent simulation blowup, 1 by default.
	 */
	public var epsilon:Float;

	/**
	 * The attenuation power of the attraction, 1 by default.
	 */
	public var attenuationPower:Float;

	/**
	 * Whether particles are viewed as equal mass, true by default.
	 *
	 * <p>
	 * When set to false, particle's mass is taken into account:
	 * heavier particles tend not to move more than lighter particles.
	 * </p>
	 */
	public var massless:Bool;

	public function new(strength:Float = 1, maxDistance:Float = 100, attenuationPower:Float = 1) {
		super();
		priority = -3;

		this.strength = strength;
		this.maxDistance = maxDistance;
		this.epsilon = 1;
		this.attenuationPower = attenuationPower;
		this.massless = true;
	}

	override private function doMutualAction(p1:Particle, p2:Particle, time:Float):Void {
		var dx:Float = p1.x - p2.x;
		var dy:Float = p1.y - p2.y;
		var dist:Float = Math.sqrt(dx * dx + dy * dy);
		if (dist < epsilon) {
			dist = epsilon;
		}

		var r:Vec2D = Vec2DPool.get(dx, dy);
		if (massless) {
			r.length = strength * Math.pow(dist, -attenuationPower);
			p2.vx += r.x * time;
			p2.vy += r.y * time;
			p1.vx -= r.x * time;
			p1.vy -= r.y * time;
		} else {
			var str:Float = strength * p1.mass * p2.mass * Math.pow(dist, -attenuationPower);
			r.length = str / p2.mass;
			p2.vx += r.x * time;
			p2.vy += r.y * time;
			r.length = str / p1.mass;
			p1.vx -= r.x * time;
			p1.vy -= r.y * time;
		}
		Vec2DPool.recycle(r);
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "MutualGravity";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("strength", strength);
		xml.set("epsilon", epsilon);
		xml.set("attenuationPower", attenuationPower);
		xml.set("massless", massless);

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.att.strength.length()) {
			strength = Std.parseFloat(xml.att.strength);
		}
		if (xml.att.epsilon.length()) {
			epsilon = Std.parseFloat(xml.att.epsilon);
		}
		if (xml.att.attenuationPower.length()) {
			attenuationPower = Std.parseFloat(xml.att.attenuationPower);
		}
		if (xml.att.massless.length()) {
			massless = (xml.att.massless == "true");
		}
	}
}
