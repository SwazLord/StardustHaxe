package com.funkypandagame.stardustplayer.project;

import openfl.Vector;
import com.funkypandagame.stardustplayer.emitter.EmitterValueObject;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.handlers.starling.StardustStarlingRenderer;
import idv.cjcat.stardustextended.handlers.starling.StarlingHandler;

class ProjectValueObject {
	public var version:Float;
	public final emitters:Map<String, EmitterValueObject> = new Map();

	public function new(_version:Float) {
		version = _version;
	}

	public function get_numberOfEmitters():Int {
		var numEmitters:Int = 0;
		for (emitter in emitters) {
			numEmitters++;
		}
		return numEmitters;
	}

	private var _numberOfParticles:Int;

	public var numberOfParticles(get, never):Int;

	public function get_numberOfParticles():Int {
		var numParticles:Int = 0;
		for (emVO in emitters) {
			numParticles += emVO.emitter.numParticles;
		}
		return numParticles;
	}

	/** Convenience function to get all emitters */
	public function get_emittersArr():Vector<Emitter> {
		var emitterVec:Vector<Emitter> = new Vector<Emitter>();
		for (emVO in emitters) {
			emitterVec.push(emVO.emitter);
		}
		return emitterVec;
	}

	/** Removes all particles and puts the simulation back to its initial state. */
	public function resetSimulation():Void {
		for (emitterValueObject in emitters) {
			emitterValueObject.emitter.reset();
		}
	}

	public function set_fps(val:Float):Void {
		for (emitterValueObject in emitters) {
			emitterValueObject.emitter.fps = val;
		}
	}

	public function get_fps():Float {
		return get_emittersArr()[0].fps;
	}

	/**
	 * The simulation will be unusable after calling this method.
	 * Note that this does *NOT* dispose StarlingHandler's texture, since textures are shared by instances.
	 * To dispose the texture call SimLoader.dispose if you dont want to create more simulations of this type.
	**/
	public function destroy():Void {
		for (emitterValueObject in emitters) {
			emitterValueObject.emitter.clearParticles();
			emitterValueObject.emitter.clearActions();
			emitterValueObject.emitter.clearInitializers();
			emitterValueObject.emitterSnapshot = null;
			var renderer:StardustStarlingRenderer = cast(emitterValueObject.emitter.particleHandler, StarlingHandler).renderer;
			// If this is not called, then Starling can call the render() function of the renderer,
			// which will try to render with disposed textures.
			renderer.advanceTime(new Vector<Particle>());
			if (renderer.parent != null) {
				renderer.parent.removeChild(renderer);
			}
			emitters.remove(emitterValueObject.id);
		}
	}
}
