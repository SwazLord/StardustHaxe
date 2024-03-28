package idv.cjcat.stardustextended.flashdisplay;

import idv.cjcat.stardustextended.xml.ClassPackage;
import idv.cjcat.stardustextended.flashdisplay.handlers.BitmapHandler;
import idv.cjcat.stardustextended.flashdisplay.handlers.DisplayObjectHandler;
import idv.cjcat.stardustextended.flashdisplay.handlers.DisplayObjectSpriteSheetHandler;
import idv.cjcat.stardustextended.flashdisplay.handlers.SingularBitmapHandler;

/**
 * Packs together classes for the classic display list.
 */
class FlashDisplayClassPackage extends ClassPackage {
	private static var _instance:FlashDisplayClassPackage;

	public static function getInstance():FlashDisplayClassPackage {
		if (_instance == null) {
			_instance = new FlashDisplayClassPackage();
		}
		return _instance;
	}

	final override private function populateClasses():Void // 2D particle handlers
	{
		classes.push(BitmapHandler);
		classes.push(DisplayObjectHandler);
		classes.push(SingularBitmapHandler);
		classes.push(DisplayObjectSpriteSheetHandler);
	}

	public function new() {
		super();
	}
}
