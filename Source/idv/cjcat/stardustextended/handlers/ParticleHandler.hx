package idv.cjcat.stardustextended.handlers;

import openfl.Vector;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.StardustElement;

/**
 * A particle handler is assigned to a particle by using the <code>Handler</code> initializer.
 * A handler monitors the beginning of an emitter step, the end of an emitter step,
 * the adding of a new particle, and the removal of a dead particle.
 * Also, the <code>readParticle()<code> method is used to read data out of <code>Particle</code>
 * objects when each particle is completely updated by actions.
 */
class ParticleHandler extends StardustElement {
	public function reset():Void {}

	/**
	 * [Abstract Method] Invoked when each emitter step begins.
	 * @param    emitter
	 * @param    particles
	 * @param    time
	 */
	public function stepBegin(emitter:Emitter, particles:Vector<Particle>, time:Float):Void {}

	/**
	 * [Abstract Method] Invoked when each emitter step ends. Particles are at their final position and ready to be
	 * rendered.
	 * @param    emitter
	 * @param    particles
	 * @param    time
	 */
	public function stepEnd(emitter:Emitter, particles:Vector<Particle>, time:Float):Void {}

	/**
	 * [Abstract Method] Invoked for each particle added.
	 * Handle particle creation in this method.
	 * @param    particle
	 */
	public function particleAdded(particle:Particle):Void {}

	/**
	 * [Abstract Method] Invoked for each particle removed.
	 * Handle particle removal in this method.
	 * @param    particle
	 */
	public function particleRemoved(particle:Particle):Void {}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "ParticleHandler";
	}

	override public function getElementTypeXMLTag():Xml {
		return Xml.parse("<handlers/>");
	}

	public function new() {
		super();
	}
}
