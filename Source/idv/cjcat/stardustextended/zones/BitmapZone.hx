package idv.cjcat.stardustextended.zones;

import openfl.utils.ByteArray;
import openfl.display.BitmapData;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;

/**
 * Zone formed by a bitmap's non-transparent pixels.
 */
class BitmapZone extends Zone {
	/**
	 * The horizontal scale of the bitmap.
	 */
	public var scaleX:Float;

	/**
	 * The vertical scale of the bitmap.
	 */
	public var scaleY:Float;

	private var xCoords:Array<Dynamic>;
	private var yCoords:Array<Dynamic>;

	public function new(bitmapData:BitmapData = null, x:Float = 0, y:Float = 0, scaleX:Float = 1, scaleY:Float = 1) {
		super();
		this.x = x;
		this.y = y;
		this.scaleX = scaleX;
		this.scaleY = scaleY;
		xCoords = [];
		yCoords = [];
		update(bitmapData);
	}

	private var bmpd:BitmapData;
	private var coordLength:Int;

	public function update(bitmapData:BitmapData = null):Void {
		if (bitmapData == null) {
			bitmapData = new BitmapData(1, 1, true, 0xFF808080);
		}

		bmpd = bitmapData.clone();

		var ba:ByteArray = bitmapData.getPixels(bitmapData.rect);
		var len:Int = ba.length >> 2;
		xCoords.resize(len);
		yCoords.resize(len);

		var xPos:Int = 0;
		var yPos:Int = 0;
		coordLength = 0;
		for (i in 0...len) {
			if (ba[i * 4] > 0) {
				xCoords[coordLength] = xPos;
				yCoords[coordLength] = yPos;
				coordLength++;
			}
			xPos++;
			if (xPos == bitmapData.width) {
				xPos = 0;
				yPos++;
			}
		}
	}

	override public function contains(x:Float, y:Float):Bool {
		var intX = Std.int(x + 0.5);
		var intY = Std.int(y + 0.5);
		var pixel = bmpd.getPixel32(intX, intY);
		var alpha = (pixel >> 24) & 0xFF;
		return alpha != 0;
	}

	override public function calculateMotionData2D():MotionData2D {
		if (xCoords.length == 0) {
			return MotionData2DPool.get(0, 0);
		}
		var index:Int = Std.int(coordLength * Math.random());
		return MotionData2DPool.get(xCoords[index] * scaleX, yCoords[index] * scaleY);
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "BitmapZone";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();
		xml.set("x", Std.string(_x));
		xml.set("y", Std.string(_y));
		xml.set("scaleX", Std.string(scaleX));
		xml.set("scaleY", Std.string(scaleY));
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("x")) {
			_x = Std.parseFloat(xml.get("x"));
		}
		if (xml.exists("x")) {
			_y = Std.parseFloat(xml.get("x"));
		}
		if (xml.exists("scaleX")) {
			scaleX = Std.parseFloat(xml.get("scaleX"));
		}
		if (xml.exists("scaleY")) {
			scaleY = Std.parseFloat(xml.get("scaleY"));
		}
	}
}
