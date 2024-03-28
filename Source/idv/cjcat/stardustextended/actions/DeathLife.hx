package idv.cjcat.stardustextended.actions;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * Mark a particle as dead if its life reaches zero.
 * <p>
 * Remember to add this action to the emitter if you wish particles to be removed from simulation when their lives reach zero.
 * Otherwise, the particles will not be removed.
 * </p>
 */
class DeathLife extends Action {
	inline final override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		if (particle.life <= 0) {
			particle.isDead = true;
		}
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "DeathLife";
	}

	public function new() {
		super();
	}
}
