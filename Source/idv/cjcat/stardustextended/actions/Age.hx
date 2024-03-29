package idv.cjcat.stardustextended.actions;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Causes a particle's life to decrease.
 */
class Age extends Action {
	/**
	 * The multiplier of aging, 1 by default.
	 *
	 * <p>
	 * For instance, a multiplier value of 2 causes a particle to age twice as fast as normal.
	 * </p>
	 *
	 * <p>
	 * Alternatively, you can assign a negative value to the multiplier.
	 * This causes a particle's age to "increase".
	 * You can then use this increasing value with <code>LifeTrigger</code> and other custom actions to create various effects.
	 * </p>
	 */
	public var multiplier:Float;

	public function new(multiplier:Float = 1) {
		super();
		this.multiplier = multiplier;
	}

	inline final override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		particle.life -= timeDelta * multiplier;
		if (particle.life < 0) {
			particle.life = 0;
		}
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "Age";
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
