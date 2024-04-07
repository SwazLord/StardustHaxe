package idv.cjcat.stardustextended.handlers;

import openfl.Vector;
import openfl.display.BitmapData;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.handlers.ParticleHandler;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.utils.ColorUtil;

/**
 * This handler draws pixels into a <code>BitmapData</code> object according to the <code>color</code> property of <code>Particle</code> objects.
 */
class PixelHandler extends ParticleHandler {
	/**
	 * The target bitmap to draw display object into.
	 */
	public var targetBitmapData:BitmapData;

	public function new(targetBitmapData:BitmapData = null) {
		super();
		this.targetBitmapData = targetBitmapData;
	}

	private var x:Int;
	private var y:Int;
	private var finalColor:Int;

	inline final override public function stepEnd(emitter:Emitter, particles:Vector<Particle>, time:Float):Void {
		for (particle in particles) {
			x = Std.int(particle.x + 0.5);

			if ((x < 0) || (x >= targetBitmapData.width)) {
				return;
			}

			y = Std.int(particle.y + 0.5);

			if ((y < 0) || (y >= targetBitmapData.height)) {
				return;
			}

			var rgbColor:Int = ColorUtil.rgbToHex(particle.colorR, particle.colorG, particle.colorB);

			finalColor = Std.int(rgbColor & 0xFFFFFF) | Std.int(Std.int(particle.alpha * 255) << 24);

			targetBitmapData.setPixel32(x, y, finalColor);
		}
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "PixelHandler";
	}
}
