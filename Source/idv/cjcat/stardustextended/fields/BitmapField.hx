package idv.cjcat.stardustextended.fields;

import openfl.display.BitmapData;
import openfl.geom.Point;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;

/**
 * Vector field based on a BitmapData.
 *
 * <p>
 * For instance, if a pixel at (10, 12) has a color of "R = 100, G = 50, B = 0",
 * and the values of the <code>channelX</code> and <code>channelY</code> are 1 (red) and 2(green), respectively (blue is 4),
 * then the coordinate (10, 12) of the field corresponds to a <code>MotionData2D</code> object with X and Y components equal to
 * "max * (100 - 128) / 255" and "max * (50 - 128) / 255", respectively.
 * </p>
 *
 * <p>
 * This field can be combined with Perlin noise bitmaps to create turbulence vector fields.
 * </p>
 */
class BitmapField extends Field {
	/**
	 * The X coordinate of the top-left coordinate.
	 */
	public var x:Float;

	/**
	 * The Y coordinate of the top-left coordinate.
	 */
	public var y:Float;

	/**
	 * The color channel for the horizontal direction.
	 */
	public var channelX:Int;

	/**
	 * The color channel for the vertical direction.
	 */
	public var channelY:Int;

	/**
	 * The maximum value of the returned <code>MotionData2D</code> object's components.
	 */
	public var max:Float;

	/**
	 * The horizontal scale of the bitmap.
	 */
	public var scaleX:Float;

	/**
	 * The vertical scale of the bitmap.
	 */
	public var scaleY:Float;

	/**
	 * Whether the bitmap tiles (i.e. repeats) infinitely.
	 */
	public var tile:Bool;

	private var _bitmapData:BitmapData;

	public function new(x:Float = 0, y:Float = 0, max:Float = 1, channelX:Int = 1, channelY:Int = 2) {
		super();
		this.x = x;
		this.y = y;
		this.max = max;
		this.channelX = channelX;
		this.channelY = channelY;
		this.scaleX = 1;
		this.scaleY = 1;
		this.tile = true;

		update();
	}

	public function update(bitmapData:BitmapData = null):Void {
		if (bitmapData == null) {
			bitmapData = new BitmapData(1, 1, false, 0x808080);
		}
		_bitmapData = bitmapData;
	}

	override private function calculateMotionData2D(particle:Particle):MotionData2D {
		var px:Float = particle.x / scaleX;
		var py:Float = particle.y / scaleY;

		if (tile) {
			px = StardustMath.mod(px, _bitmapData.width);
			py = StardustMath.mod(py, _bitmapData.height);
		} else if ((px < 0) || (px >= _bitmapData.width) || (py < 0) || (py >= _bitmapData.height)) {
			return null;
		}
		var finalX:Float = 0;
		var finalY:Float = 0;
		var color:Int = _bitmapData.getPixel(Std.int(px), Std.int(py));
		switch (channelX) {
			case 1:
				finalX = 2 * ((((color & 0xFF0000) >> 16) / 255) - 0.5) * max;
			case 2:
				finalX = 2 * ((((color & 0x00FF00) >> 8) / 255) - 0.5) * max;
			case 4:
				finalX = 2 * (((color & 0x0000FF) / 255) - 0.5) * max;
		}

		switch (channelY) {
			case 1:
				finalY = 2 * ((((color & 0xFF0000) >> 16) / 255) - 0.5) * max;
			case 2:
				finalY = 2 * ((((color & 0x00FF00) >> 8) / 255) - 0.5) * max;
			case 4:
				finalY = 2 * (((color & 0x0000FF) / 255) - 0.5) * max;
		}

		return MotionData2DPool.get(finalX, finalY);
	}

	override public function setPosition(xc:Float, yc:Float):Void {
		x = xc;
		y = yc;
	}

	override public function getPosition():Point {
		position.setTo(x, y);
		return position;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "BitmapField";
	}

	override public function toXML():Xml {
		var xml:Xml = cast super.toXML();

		// Set attributes with potential string conversion (optional)
		xml.set("x", Std.string(x));
		xml.set("y", Std.string(y));
		xml.set("channelX", Std.string(channelX));
		xml.set("channelY", Std.string(channelY));
		xml.set("max", Std.string(max));
		xml.set("scaleX", Std.string(scaleX));
		xml.set("scaleY", Std.string(scaleY));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		// Check for attribute existence and parse floats (assuming string attributes)
		if (xml.exists("x")) {
			x = Std.parseFloat(xml.get("x"));
		}
		if (xml.exists("y")) {
			y = Std.parseFloat(xml.get("y"));
		}
		if (xml.exists("channelX")) {
			channelX = Std.int(Std.parseFloat(xml.get("channelX")));
		}
		if (xml.exists("channelY")) {
			channelY = Std.int(Std.parseFloat(xml.get("channelY")));
		}
		if (xml.exists("max")) {
			max = Std.parseFloat(xml.get("max"));
		}
		if (xml.exists("scaleX")) {
			scaleX = Std.parseFloat(xml.get("scaleX"));
		}
		if (xml.exists("scaleY")) {
			scaleY = Std.parseFloat(xml.get("scaleY"));
		}
	}
}
