package idv.cjcat.stardustextended.actions.triggers;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * This action trigger return true if a particle is dead.
 */
class DeathTrigger extends Trigger {
	final override public function testTrigger(emitter:Emitter, particle:Particle, time:Float):Bool {
		return particle.isDead;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "DeathTrigger";
	}

	public function new() {
		super();
	}
}
