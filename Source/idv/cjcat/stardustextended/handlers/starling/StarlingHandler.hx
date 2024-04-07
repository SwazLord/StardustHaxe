package idv.cjcat.stardustextended.handlers.starling;

import openfl.Vector;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.handlers.ISpriteSheetHandler;
import idv.cjcat.stardustextended.handlers.ParticleHandler;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import starling.display.BlendMode;
import starling.display.DisplayObjectContainer;
import starling.textures.SubTexture;
import starling.textures.TextureSmoothing;

class StarlingHandler extends ParticleHandler implements ISpriteSheetHandler {
	public var container(never, set):DisplayObjectContainer;
	public var renderer(get, never):StardustStarlingRenderer;
	public var spriteSheetAnimationSpeed(get, set):Int;
	public var spriteSheetStartAtRandomFrame(get, set):Bool;
	public var isSpriteSheet(get, never):Bool;
	public var smoothing(get, set):Bool;
	public var premultiplyAlpha(get, set):Bool;
	public var blendMode(get, set):String;
	public var textures(get, never):Vector<SubTexture>;

	private var _blendMode:String = BlendMode.NORMAL;
	private var _spriteSheetAnimationSpeed:Int = 1;
	private var _smoothing:String = TextureSmoothing.NONE;
	private var _isSpriteSheet:Bool;
	private var _premultiplyAlpha:Bool = true;
	private var _spriteSheetStartAtRandomFrame:Bool;
	private var _totalFrames:Int;
	private var _textures:Vector<SubTexture>;
	private var _renderer:StardustStarlingRenderer;
	private var timeSinceLastStep:Float;

	public function new() {
		super();
		timeSinceLastStep = 0;
	}

	override public function reset():Void {
		timeSinceLastStep = 0;
		_renderer.advanceTime(new Vector<Particle>());
	}

	private function set_container(container:DisplayObjectContainer):DisplayObjectContainer {
		createRendererIfNeeded();
		container.addChild(_renderer);
		return container;
	}

	public function createRendererIfNeeded():Void {
		if (_renderer == null) {
			_renderer = new StardustStarlingRenderer();
			_renderer.blendMode = _blendMode;
			_renderer.texSmoothing = _smoothing;
			_renderer.premultiplyAlpha = _premultiplyAlpha;
		}
	}

	private var _stepSize:Int;
	private var _mNumParticles:Int;

	private var _particle:Particle;
	private var _currentFrame:Int;

	private var _i:Int;

	inline override public function stepEnd(emitter:Emitter, particles:Vector<Particle>, time:Float):Void {
		if (_isSpriteSheet && _spriteSheetAnimationSpeed > 0) {
			timeSinceLastStep = timeSinceLastStep + time;

			if (timeSinceLastStep > 1 / _spriteSheetAnimationSpeed) {
				_stepSize = Math.floor(timeSinceLastStep * _spriteSheetAnimationSpeed);
				_mNumParticles = particles.length;

				for (_i in 0..._mNumParticles) {
					_particle = particles[_i];
					_currentFrame = _particle.currentAnimationFrame;

					_currentFrame = Std.int(_currentFrame + _stepSize);

					if (_currentFrame >= _totalFrames) {
						_currentFrame = 0;
					}

					_particle.currentAnimationFrame = _currentFrame;
				}

				timeSinceLastStep = 0;
			}
		}

		_renderer.advanceTime(particles);
	}

	inline final override public function particleAdded(particle:Particle):Void {
		if (_isSpriteSheet) {
			var currFrame:Int = 0;

			if (_spriteSheetStartAtRandomFrame) {
				currFrame = Std.int(Math.random() * _totalFrames);
			}

			particle.currentAnimationFrame = currFrame;
		} else {
			particle.currentAnimationFrame = 0;
		}
	}

	private function get_renderer():StardustStarlingRenderer {
		return _renderer;
	}

	private function set_spriteSheetAnimationSpeed(spriteSheetAnimationSpeed:Int):Int {
		_spriteSheetAnimationSpeed = spriteSheetAnimationSpeed;

		if (_textures != null) {
			setTextures(_textures);
		}
		return spriteSheetAnimationSpeed;
	}

	private function get_spriteSheetAnimationSpeed():Int {
		return _spriteSheetAnimationSpeed;
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
		return _smoothing != TextureSmoothing.NONE;
	}

	private function set_smoothing(value:Bool):Bool {
		if (value == true) {
			_smoothing = TextureSmoothing.BILINEAR;
		} else {
			_smoothing = TextureSmoothing.NONE;
		}
		createRendererIfNeeded();
		_renderer.texSmoothing = _smoothing;
		return value;
	}

	private function get_premultiplyAlpha():Bool {
		return _premultiplyAlpha;
	}

	private function set_premultiplyAlpha(value:Bool):Bool {
		_premultiplyAlpha = value;
		createRendererIfNeeded();
		_renderer.premultiplyAlpha = value;
		return value;
	}

	private function set_blendMode(blendMode:String):String {
		_blendMode = blendMode;
		createRendererIfNeeded();
		_renderer.blendMode = blendMode;
		return blendMode;
	}

	private function get_blendMode():String {
		return _blendMode;
	}

	/** Sets the textures directly. Stardust can batch the simulations resulting multiple simulations using
	 *  just one draw call. To have this working the following must be met:
	 *  - The textures must come from the same sprite sheet. (= they must have the same base texture)
	 *  - The simulations must have the same render target, smoothing, blendMode, same filter
	 *    and the same premultiplyAlpha values.
	**/
	final public function setTextures(textures:Vector<SubTexture>):Void {
		if (textures == null || textures.length == 0) {
			throw new ArgumentError("the textures parameter cannot be null and needs to hold at least 1 element");
		}

		createRendererIfNeeded();

		_isSpriteSheet = textures.length > 1;
		_textures = textures;

		var frames:Vector<Frame> = new Vector<Frame>();

		for (texture in textures) {
			if (texture.root != textures[0].root) {
				throw new Error("The texture " + texture + " does not share the same base root with others");
			}
			// TODO use the transformationMatrix
			var frame:Frame = new Frame(texture.region.x / texture.root.width, texture.region.y / texture.root.height,
				(texture.region.x + texture.region.width) / texture.root.width, (texture.region.y + texture.region.height) / texture.root.height,
				texture.width * 0.5, texture.height * 0.5);
			frames.push(frame);
		}
		_totalFrames = frames.length;
		_renderer.setTextures(textures[0].root, frames);
	}

	private function get_textures():Vector<SubTexture> {
		return _textures;
	}

	//////////////////////////////////////////////////////// Xml
	override public function getXMLTagName():String {
		return "StarlingHandler";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();
		xml.set("spriteSheetAnimationSpeed", Std.string(_spriteSheetAnimationSpeed));
		xml.set("spriteSheetStartAtRandomFrame", Std.string(_spriteSheetStartAtRandomFrame));
		xml.set("smoothing", Std.string(smoothing));
		xml.set("blendMode", Std.string(_blendMode));
		xml.set("premultiplyAlpha", Std.string(_premultiplyAlpha));
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);
		_spriteSheetAnimationSpeed = Std.parseInt(xml.get("spriteSheetAnimationSpeed"));
		_spriteSheetStartAtRandomFrame = (xml.get("spriteSheetStartAtRandomFrame") == "true");
		smoothing = (xml.get("smoothing") == "true");
		blendMode = (xml.get("blendMode"));
		premultiplyAlpha = (xml.get("premultiplyAlpha") == "true");
	}
}
