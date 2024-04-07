package idv.cjcat.stardustextended.actions;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Causes particles to decelerate.
 * Its recommended to use Accelerate with <0 values instead of this class.
 * <p>
 * Default priority = -1;
 * </p>
 */
class Damping extends Action {
	/**
	 * In each emitter second, each particle's velocity is multiplied by this value.
	 *
	 * <p>
	 * A value of 0 denotes no damping at all, and a value of 1 means all particles will not move at all.
	 * </p>
	 */
	public var damping:Float;

	public function new(damping:Float = 0.05) {
		super();
		priority = -1;

		this.damping = damping;
	}

	override public function preUpdate(emitter:Emitter, time:Float):Void {
		damp = 1;
		if (damping != 0 && !Math.isNaN(damping)) {
			damp = Math.pow(1 - damping, time * 60);
		}
	}

	private var damp:Float;

	override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		particle.vx *= damp;
		particle.vy *= damp;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "Damping";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("damping", Std.string(damping));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("damping")) {
			damping = Std.parseFloat(xml.get("damping"));
		}
	}
}
