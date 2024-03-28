package idv.cjcat.stardustextended.flashdisplay.particletargets;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;

class CenteredBitmap extends Sprite {
	public var smoothing(get, set):Bool;
	public var bitmapData(get, set):BitmapData;

	private var bmp:Bitmap;

	public function new() {
		super();
		bmp = new Bitmap();
		addChild(bmp);
	}

	private function get_smoothing():Bool {
		return bmp.smoothing;
	}

	private function set_smoothing(value:Bool):Bool {
		bmp.smoothing = value;
		return value;
	}

	private function get_bitmapData():BitmapData {
		return bmp.bitmapData;
	}

	private function set_bitmapData(value:BitmapData):BitmapData {
		bmp.bitmapData = value;
		bmp.x = -bmp.width * 0.5;
		bmp.y = -bmp.height * 0.5;
		return value;
	}
}
