package;


import openfl.display.Sprite;
import starling.core.Starling;


class Startup extends Sprite {
	
	
	private var starling:Starling;
	
	
	public function new () {
		
		super ();
		stage.color = 0x565656;
		stage.frameRate = 60;
		starling = new Starling (Game, stage);
		starling.start ();
		
	}
	
	
}