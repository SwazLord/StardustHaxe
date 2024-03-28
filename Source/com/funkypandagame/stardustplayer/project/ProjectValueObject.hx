package com.funkypandagame.stardustplayer.project;

import com.funkypandagame.stardustplayer.emitter.EmitterValueObject;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.handlers.starling.StardustStarlingRenderer;
import idv.cjcat.stardustextended.handlers.starling.StarlingHandler;

class ProjectValueObject {
	public var numberOfEmitters(get, never):Int;
	public var numberOfParticles(get, never):Int;
	public var emittersArr(get, never):Array<Emitter>;
	public var fps(get, set):Float;

	public var version:Float;

	public static final emitters = new Map<String, Any>(); // of EmitterValueObject

	public function new(_version:Float) {
		version = _version;
	}

	private function get_numberOfEmitters():Int {
		var numEmitters:Int = 0;
		for (emitter /* AS3HX WARNING could not determine type for var: emitter exp: EIdent(emitters) type: Dictionary */ in emitters) {
			numEmitters++;
		}
		return numEmitters;
	}

	private function get_numberOfParticles():Int {
		var numParticles:Int = 0;
		for (emVO /* AS3HX WARNING could not determine type for var: emVO exp: EIdent(emitters) type: Dictionary */ in emitters) {
			numParticles += emVO.emitter.numParticles;
		}
		return numParticles;
	}

	/** Convenience function to get all emitters */
	private function get_emittersArr():Array<Emitter> {
		var emitterVec:Array<Emitter> = new Array<Emitter>();
		for (emVO /* AS3HX WARNING could not determine type for var: emVO exp: EIdent(emitters) type: Dictionary */ in emitters) {
			emitterVec.push(emVO.emitter);
		}
		return emitterVec;
	}

	/** Removes all particles and puts the simulation back to its initial state. */
	public function resetSimulation():Void {
		for (emitterValueObject /* AS3HX WARNING could not determine type for var: emitterValueObject exp: EIdent(emitters) type: Dictionary */ in emitters) {
			emitterValueObject.emitter.reset();
		}
	}

	private function set_fps(val:Float):Float {
		for (emitterValueObject /* AS3HX WARNING could not determine type for var: emitterValueObject exp: EIdent(emitters) type: Dictionary */ in emitters) {
			emitterValueObject.emitter.fps = val;
		}
		return val;
	}

	private function get_fps():Float {
		return emittersArr[0].fps;
	}

	/**
	 * The simulation will be unusable after calling this method.
	 * Note that this does *NOT* dispose StarlingHandler's texture, since textures are shared by instances.
	 * To dispose the texture call SimLoader.dispose if you dont want to create more simulations of this type.
	**/
	public function destroy():Void {
		for (emitterValueObject /* AS3HX WARNING could not determine type for var: emitterValueObject exp: EIdent(emitters) type: Dictionary */ in emitters) {
			emitterValueObject.emitter.clearParticles();
			emitterValueObject.emitter.clearActions();
			emitterValueObject.emitter.clearInitializers();
			emitterValueObject.emitterSnapshot = null;
			var renderer:StardustStarlingRenderer = cast((emitterValueObject.emitter.particleHandler), StarlingHandler).renderer;
			// If this is not called, then Starling can call the render() function of the renderer,
			// which will try to render with disposed textures.
			renderer.advanceTime(new Array<Particle>());
			if (renderer.parent) {
				renderer.parent.removeChild(renderer);
			}
			// This is an intentional compilation error. See the README for handling the delete keyword
			emitters.remove(emitterValueObject.id);
		}
	}
}
