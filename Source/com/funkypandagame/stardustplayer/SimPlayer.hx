package com.funkypandagame.stardustplayer;

import openfl.errors.Error;
import com.funkypandagame.stardustplayer.emitter.EmitterValueObject;
import com.funkypandagame.stardustplayer.project.ProjectValueObject;
import idv.cjcat.stardustextended.handlers.starling.StarlingHandler;
import starling.display.DisplayObjectContainer;

/** Simple class to play back simulations. */
class SimPlayer {
	private var _project:ProjectValueObject;
	private var _renderTarget:DisplayObjectContainer;

	public function setProject(sim:ProjectValueObject):Void {
		if (sim == null) {
			trace("WARNING: A simulation can not be null");
		}
		_project = sim;
		setupSimulation();
	}

	public function setRenderTarget(renderTarget:DisplayObjectContainer):Void {
		if (renderTarget == null) {
			trace("renderTarget cannot be null");
		}
		_renderTarget = renderTarget;
		setupSimulation();
	}

	private function setupSimulation():Void {
		if (_renderTarget == null || _project == null) {
			return;
		}
		for (emitter /* AS3HX WARNING could not determine type for var: emitter exp: EField(EIdent(_project),emitters) type: null */ in _project.emitters) {
			cast((emitter.emitter.particleHandler), StarlingHandler).container = try cast(_renderTarget, DisplayObjectContainer) catch (e:Dynamic) null;
		}
	}

	public function getProject():ProjectValueObject {
		return _project;
	}

	public function stepSimulation(deltaTime:Float):Void {
		if (_project == null || _renderTarget == null) {
			throw new Error("The simulation and its render target must be set.");
		}
		for (emVO /* AS3HX WARNING could not determine type for var: emVO exp: EField(EIdent(_project),emitters) type: null */ in _project.emitters) {
			emVO.emitter.step(deltaTime);
		}
	}

	public function new() {}
}
