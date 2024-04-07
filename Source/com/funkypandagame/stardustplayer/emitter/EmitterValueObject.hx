package com.funkypandagame.stardustplayer.emitter;

import openfl.Vector;
import com.funkypandagame.stardustplayer.Particle2DSnapshot;
import openfl.Lib.registerClassAlias;
import openfl.utils.ByteArray;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.particles.PooledParticleFactory;
import idv.cjcat.stardustextended.handlers.starling.StarlingHandler;
import starling.textures.SubTexture;

class EmitterValueObject {
	public var id(get, never):String;
	public var textures(get, never):Vector<SubTexture>;

	public var emitter:Emitter;

	/** Snapshot of the particles. If its not null then the emitter will have the particles stored here upon creation. */
	public var emitterSnapshot:ByteArray;

	public function new(_emitter:Emitter) {
		emitter = _emitter;
	}

	private function get_id():String {
		return emitter.name;
	}

	private function get_textures():Vector<SubTexture> {
		return cast((emitter.particleHandler), StarlingHandler).textures;
	}

	public function addParticlesFromSnapshot():Void {
		registerClassAlias(Type.getClassName(Particle2DSnapshot), Particle2DSnapshot);
		emitterSnapshot.position = 0;
		var particlesData:Array<Dynamic> = emitterSnapshot.readObject();
		var factory:PooledParticleFactory = new PooledParticleFactory();
		var particles:Vector<Particle> = factory.createParticles(particlesData.length, 0);
		for (j in 0...particlesData.length) {
			cast((particlesData[j]), Particle2DSnapshot).writeDataTo(particles[j]);
		}
		emitter.addParticles(particles);
	}
}
