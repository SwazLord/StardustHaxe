import openfl.events.Event;
import openfl.Assets;
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
	private var simContainer:Sprite;
	private var player:SimPlayer;
	private var loader:SimLoader;
	private var infoTF:TextField;
	private var project:ProjectValueObject;
	private var cnt:UInt = 0;

	private static var assetInstance:ByteArray;

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

		assetInstance = Assets.getBytes("assets/coinShower_simple.sde");
		// assetInstance = Assets.getBytes("assets/exampleSim.sde");
		// assetInstance = Assets.getBytes("assets/snowfall.sde");
		// assetInstance = Assets.getBytes("assets/blazing_fire.sde");
		// assetInstance = Assets.getBytes("assets/gravityFields.sde");
		// assetInstance = Assets.getBytes("assets/fireworks.sde");
		// assetInstance = Assets.getBytes("assets/rocket.sde");
		//assetInstance = Assets.getBytes("assets/dryIce.sde");
		// assetInstance = Assets.getBytes("assets/glitterBurst.sde");
		// assetInstance = Assets.getBytes("assets/bigExplosion.sde");

		player = new SimPlayer();
		loader = new SimLoader();
		loader.addEventListener(Event.COMPLETE, onSimLoaded);
		loader.loadSim(assetInstance);
	}

	private function onSimLoaded(event:Event):Void {
		trace("sim loaded");
		loader.removeEventListener(Event.COMPLETE, onSimLoaded);
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
