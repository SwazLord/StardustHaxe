package idv.cjcat.stardustextended.actions;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * Instantly marks a particle as dead.
 *
 * <p>
 * This action should be used with action triggers.
 * If this action is directly added to an emitter, all particles will be marked dead upon birth.
 * </p>
 */
class Die extends Action {
	final override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		particle.isDead = true;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "Die";
	}

	public function new() {
		super();
	}
}
