package idv.cjcat.stardustextended.actions;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Causes a particle's rotation to change according to it's omega value (angular velocity).
 *
 * <p>
 * Default priority = -4;
 * </p>
 */
class Spin extends Action {
	/**
	 * The multiplier of spinning, 1 by default.
	 *
	 * <p>
	 * For instance, a multiplier value of 2 causes a particle to spin twice as fast as normal.
	 * </p>
	 */
	public var multiplier:Float;

	private var factor:Float;

	public function new(_multiplier:Float = 1) {
		super();
		priority = -4;
		multiplier = _multiplier;
	}

	override public function preUpdate(emitter:Emitter, time:Float):Void {
		factor = time * multiplier;
	}

	override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		particle.rotation += particle.omega * factor;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "Spin";
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
