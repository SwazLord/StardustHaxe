package idv.cjcat.stardustextended.actions;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Causes a particle's position to change according to its velocity.
 *
 * <p>
 * Default priority = -4;
 * </p>
 */
class Move extends Action {
	/**
	 * The multiplier of movement, 1 by default.
	 *
	 * <p>
	 * For instance, a multiplier value of 2 causes a particle to move twice as fast as normal.
	 * </p>
	 */
	public var multiplier:Float;

	private var factor:Float;

	public function new(multiplier:Float = 1) {
		super();
		priority = -4;

		this.multiplier = multiplier;
	}

	override public function preUpdate(emitter:Emitter, time:Float):Void {
		factor = time * multiplier;
	}

	inline final override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		particle.x += particle.vx * factor;
		particle.y += particle.vy * factor;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "Move";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("multiplier", Std.string(multiplier));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("multiplier")) {
			multiplier = Std.parseFloat(xml.get("multiplier"));
		}
	}
}
