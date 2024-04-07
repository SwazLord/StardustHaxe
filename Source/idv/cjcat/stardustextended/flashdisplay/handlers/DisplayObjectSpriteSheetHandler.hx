package idv.cjcat.stardustextended.flashdisplay.handlers;

import openfl.display.DisplayObject;
import openfl.geom.ColorTransform;
import openfl.display.DisplayObjectContainer;
import openfl.Vector;
import openfl.display.BitmapData;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.flashdisplay.particletargets.CenteredBitmap;
import idv.cjcat.stardustextended.flashdisplay.utils.DisplayObjectPool;
import idv.cjcat.stardustextended.handlers.ISpriteSheetHandler;

class DisplayObjectSpriteSheetHandler extends DisplayObjectHandler implements ISpriteSheetHandler {
	public var spriteSheetAnimationSpeed(get, set):Int;
	public var spriteSheetStartAtRandomFrame(get, set):Bool;
	public var isSpriteSheet(get, never):Bool;
	public var smoothing(get, set):Bool;

	private var _spriteSheetStartAtRandomFrame:Bool;
	private var _smoothing:Bool;
	private var _spriteSheetAnimationSpeed:Float;
	private var _pool:DisplayObjectPool;
	private var _totalFrames:Int;
	private var _isSpriteSheet:Bool;
	private var _images:Vector<BitmapData>;

	public function new(container:DisplayObjectContainer = null, blendMode:String = "normal", addChildMode:Int = 0) {
		super(container, blendMode, addChildMode);
		_pool = new DisplayObjectPool();
		_pool.reset(CenteredBitmap, null);
	}

	override public function stepEnd(emitter:Emitter, particles:Vector<Particle>, time:Float):Void {
		super.stepEnd(emitter, particles, time);
		for (particle in particles) {
			var bmp:CenteredBitmap = cast((particle.target), CenteredBitmap);
			if (_isSpriteSheet && _spriteSheetAnimationSpeed > 0) {
				var currFrame:Int = particle.currentAnimationFrame;
				var nextFrame:Int = Std.int((currFrame + time) % _totalFrames);
				var nextImageIndex:Int = Std.int(nextFrame / _spriteSheetAnimationSpeed);
				var currImageIndex:Int = Std.int(currFrame / _spriteSheetAnimationSpeed);
				if (nextImageIndex != currImageIndex) {
					bmp.bitmapData = _images[nextImageIndex];
					bmp.smoothing = _smoothing;
				}
				particle.currentAnimationFrame = nextFrame;
			}
			// optimize this if possible
			bmp.transform.colorTransform = new ColorTransform(particle.colorR, particle.colorG, particle.colorB, particle.alpha);
		}
	}

	override public function particleAdded(particle:Particle):Void {
		var bmp:CenteredBitmap = cast((_pool.get()), CenteredBitmap);
		particle.target = bmp;

		if (_isSpriteSheet) {
			makeSpriteSheetCache();
			var currFrame:Int = 0;
			if (_spriteSheetStartAtRandomFrame) {
				currFrame = Std.int(Math.random() * _totalFrames);
			}
			if (_spriteSheetAnimationSpeed > 0) {
				bmp.bitmapData = _images[Std.int(currFrame / _spriteSheetAnimationSpeed)];
			} else {
				bmp.bitmapData = _images[currFrame];
			}
			particle.currentAnimationFrame = currFrame;
		} else {
			bmp.bitmapData = _images[0];
		}
		bmp.smoothing = _smoothing;

		bmp.transform.colorTransform = new ColorTransform(particle.colorR, particle.colorG, particle.colorB, particle.alpha);

		super.particleAdded(particle);
	}

	override public function particleRemoved(particle:Particle):Void {
		super.particleRemoved(particle);
		var obj:DisplayObject = cast((particle.target), DisplayObject);
		if (obj != null) {
			_pool.recycle(obj);
		}
	}

	public function setImages(images:Vector<BitmapData>):Void {
		_images = images;
		makeSpriteSheetCache();
	}

	private function set_spriteSheetAnimationSpeed(spriteSheetAnimationSpeed:Int):Int {
		_spriteSheetAnimationSpeed = spriteSheetAnimationSpeed;
		makeSpriteSheetCache();
		return spriteSheetAnimationSpeed;
	}

	private function get_spriteSheetAnimationSpeed():Int {
		return Std.int(_spriteSheetAnimationSpeed);
	}

	private function set_spriteSheetStartAtRandomFrame(spriteSheetStartAtRandomFrame:Bool):Bool {
		_spriteSheetStartAtRandomFrame = spriteSheetStartAtRandomFrame;
		return spriteSheetStartAtRandomFrame;
	}

	private function get_spriteSheetStartAtRandomFrame():Bool {
		return _spriteSheetStartAtRandomFrame;
	}

	private function get_isSpriteSheet():Bool {
		return _isSpriteSheet;
	}

	private function get_smoothing():Bool {
		return _smoothing;
	}

	private function set_smoothing(value:Bool):Bool {
		_smoothing = value;
		return value;
	}

	private function makeSpriteSheetCache():Void {
		if (_images == null) {
			return;
		}
		_isSpriteSheet = _images.length > 1;
		var numStates:Int = Std.int(_spriteSheetAnimationSpeed);
		if (numStates == 0) {
			numStates = 1;
		}
		_totalFrames = Std.int(numStates * _images.length);
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "DisplayObjectSpriteSheetHandler";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();
		xml.set("spriteSheetAnimationSpeed", Std.string(_spriteSheetAnimationSpeed));
		xml.set("spriteSheetStartAtRandomFrame", Std.string(_spriteSheetStartAtRandomFrame));
		xml.set("smoothing", Std.string(_smoothing));
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);
		_spriteSheetAnimationSpeed = Std.parseFloat(xml.get("spriteSheetAnimationSpeed"));
		_spriteSheetStartAtRandomFrame = (xml.get("spriteSheetStartAtRandomFrame") == "true");
		_smoothing = (xml.get("smoothing") == "true");
		makeSpriteSheetCache();
	}
}
