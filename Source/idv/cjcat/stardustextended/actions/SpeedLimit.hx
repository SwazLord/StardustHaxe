package idv.cjcat.stardustextended.actions;

import idv.cjcat.stardustextended.actions.Action;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Limits a particle's maximum traveling speed.
 */
class SpeedLimit extends Action {
	/**
	 * The speed limit.
	 */
	public var limit:Float;

	public function new(limit:Float = as3hx.Compat.FLOAT_MAX) {
		super();
		this.limit = limit;
	}

	override public function preUpdate(emitter:Emitter, time:Float):Void {
		limitSQ = limit * limit;
	}

	private var speedSQ:Float;
	private var limitSQ:Float;
	private var factor:Float;

	override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		speedSQ = particle.vx * particle.vx + particle.vy * particle.vy;
		if (speedSQ > limitSQ) {
			factor = limit / Math.sqrt(speedSQ);
			particle.vx *= factor;
			particle.vy *= factor;
		}
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "SpeedLimit";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.setAttribute("limit", limit);

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.att.limit.length()) {
			limit = as3hx.Compat.parseFloat(xml.att.limit);
		}
	}
}
