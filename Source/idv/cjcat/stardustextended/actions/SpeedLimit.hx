package idv.cjcat.stardustextended.actions;

import starling.utils.MathUtil;
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

	public function new(lim:Float = 1e+308) {
		super();
		this.limit = lim;
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

		xml.set("limit", Std.string(limit));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("limit")) {
			limit = Std.parseFloat(xml.get("limit"));
		}
	}
}
