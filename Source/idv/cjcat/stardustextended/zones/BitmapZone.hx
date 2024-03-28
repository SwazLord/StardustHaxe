package idv.cjcat.stardustextended.zones;

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
		as3hx.Compat.setArrayLength(xCoords, as3hx.Compat.setArrayLength(yCoords, len));

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
		x = as3hx.Compat.parseInt(x + 0.5);
		y = as3hx.Compat.parseInt(y + 0.5);
		if (as3hx.Compat.parseInt(bmpd.getPixel32(x, y) >> 24)) {
			return true;
		}
		return false;
	}

	override public function calculateMotionData2D():MotionData2D {
		if (xCoords.length == 0) {
			return MotionData2DPool.get(0, 0);
		}
		var index:Int = as3hx.Compat.parseInt(coordLength * Math.random());
		return MotionData2DPool.get(xCoords[index] * scaleX, yCoords[index] * scaleY);
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "BitmapZone";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();
		xml.setAttribute("x", _x);
		xml.setAttribute("y", _y);
		xml.setAttribute("scaleX", scaleX);
		xml.setAttribute("scaleY", scaleY);
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.att.x.length()) {
			_x = as3hx.Compat.parseFloat(xml.att.x);
		}
		if (xml.att.y.length()) {
			_y = as3hx.Compat.parseFloat(xml.att.y);
		}
		if (xml.att.scaleX.length()) {
			scaleX = as3hx.Compat.parseFloat(xml.att.scaleX);
		}
		if (xml.att.scaleY.length()) {
			scaleY = as3hx.Compat.parseFloat(xml.att.scaleY);
		}
	}
}
