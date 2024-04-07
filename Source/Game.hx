import com.funkypandagame.stardustplayer.SimLoader;
import com.funkypandagame.stardustplayer.SimPlayer;
import com.funkypandagame.stardustplayer.emitter.EmitterValueObject;
import com.funkypandagame.stardustplayer.project.ProjectValueObject;
import idv.cjcat.stardustextended.clocks.*;
import openfl.utils.ByteArray;
import starling.core.Starling;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.text.TextField;
import starling.utils.Align;
import starling.utils.Color;

class Game extends Sprite {
	@:embed(source = "/../Assets/coinShower_simple.sde", mimeType = "application/octet-stream")
	private static var Asset:Class;

	private var simContainer:Sprite;
	private var player:SimPlayer;
	private var loader:SimLoader;
	private var infoTF:TextField;
	private var project:ProjectValueObject;
	private var cnt:UInt = 0;

	public function new() {
		super();
		Starling.current.showStatsAt(Align.LEFT, Align.BOTTOM);

		simContainer = new Sprite();
		simContainer.touchable = false;
		addChild(simContainer);
		simContainer.x = 300;
		simContainer.y = 300;

		infoTF = new TextField(250, 30, "");
		infoTF.format.setTo("Verdana", 14, Color.WHITE);
		addChild(infoTF);

		player = new SimPlayer();
		loader = new SimLoader();
		loader.addEventListener(flash.events.Event.COMPLETE, onSimLoaded);
		loader.loadSim(Asset);
	}

	private function onSimLoaded(event:flash.events.Event):Void {
		loader.removeEventListener(flash.events.Event.COMPLETE, onSimLoaded);
		project = loader.createProjectInstance();
		player.setProject(project);
		player.setRenderTarget(simContainer);
		// step the simulation on every frame
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
	}

	private function onEnterFrame(event:EnterFrameEvent):Void {
		player.stepSimulation(event.passedTime);
		cnt++;
		if (cnt % 60 == 0) {
			infoTF.text = "particles: " + project.numberOfParticles;
		}
	}
}
