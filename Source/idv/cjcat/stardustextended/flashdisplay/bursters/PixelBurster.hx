package idv.cjcat.stardustextended.flashdisplay.bursters;

import openfl.Vector;
import openfl.display.BitmapData;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.utils.ColorUtil;

class PixelBurster extends Burster {
	/**
	 * The X coordinate of the top-left corner of the top-left cell.
	 */
	public var offsetX:Float;

	/**
	 * The Y coordinate of the top-left corner of the top-left cell.
	 */
	public var offsetY:Float;

	public var bitmapData:BitmapData;

	public function new(offsetX:Float = 0, offsetY:Float = 0) {
		super();
		this.offsetX = offsetX;
		this.offsetY = offsetY;
	}

	override public function createParticles(currentTime:Float):Vector<Particle> {
		if (bitmapData == null) {
			return null;
		}

		var rows:Int = bitmapData.height;
		var columns:Int = bitmapData.width;
		var particles:Vector<Particle> = factory.createParticles(rows * columns, currentTime);

		var index:Int = 0;
		var p:Particle;
		var inv255:Float = 1 / 255;
		for (j in 0...rows) {
			for (i in 0...columns) {
				p = particles[index];
				var color:Int = bitmapData.getPixel32(i, j);
				p.alpha = Std.parseFloat(Std.string(Std.int(color & 0xFF000000) >> 24)) * inv255;
				if (p.alpha == 0) {
					continue;
				}
				var colorNoAlpha:Int = color & 0xFFFFFF;
				p.colorR = ColorUtil.extractRed(colorNoAlpha);
				p.colorG = ColorUtil.extractGreen(colorNoAlpha);
				p.colorB = ColorUtil.extractBlue(colorNoAlpha);
				p.x = i + offsetX;
				p.y = j + offsetY;

				index++;
			}
		}

		return particles;
	}
}
