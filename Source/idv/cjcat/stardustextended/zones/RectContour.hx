package idv.cjcat.stardustextended.zones;

import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Rectangular contour.
 */
class RectContour extends Composite {
	public var width(get, set):Float;
	public var height(get, set):Float;
	public var virtualThickness(get, set):Float;

	private var _virtualThickness:Float;

	private var _width:Float;
	private var _height:Float;

	private var _line1:Line;
	private var _line2:Line;
	private var _line3:Line;
	private var _line4:Line;

	public function new(x:Float = 0, y:Float = 0, _width:Float = 200, _height:Float = 100) {
		super();
		_line1 = new Line();
		_line2 = new Line();
		_line3 = new Line();
		_line4 = new Line();

		addZone(_line1);
		addZone(_line2);
		addZone(_line3);
		addZone(_line4);

		virtualThickness = 1;

		_x = x;
		_y = y;
		width = _width;
		height = _height;

		updateArea();
	}

	override public function getPoint():MotionData2D {
		var md2D:MotionData2D = super.getPoint();
		if (_rotation != 0) {
			var originalX:Float = md2D.x;
			md2D.x = originalX * angleCos - md2D.y * angleSin;
			md2D.y = originalX * angleSin + md2D.y * angleCos;
		}
		md2D.x = _x + md2D.x;
		md2D.y = _y + md2D.y;
		return md2D;
	}

	private function get_width():Float {
		return _width;
	}

	private function set_width(value:Float):Float {
		_width = value;
		updateContour();
		updateArea();
		return value;
	}

	private function get_height():Float {
		return _height;
	}

	private function set_height(value:Float):Float {
		_height = value;
		updateContour();
		updateArea();
		return value;
	}

	private function get_virtualThickness():Float {
		return _virtualThickness;
	}

	private function set_virtualThickness(value:Float):Float {
		_virtualThickness = value;
		_line1.virtualThickness = value;
		_line2.virtualThickness = value;
		_line3.virtualThickness = value;
		_line4.virtualThickness = value;
		updateArea();
		return value;
	}

	private function updateContour():Void {
		_line1.x = 0;
		_line1.y = 0;
		_line1.x2 = width;
		_line1.y2 = 0;

		_line2.x = 0;
		_line2.y = height;
		_line2.x2 = width;
		_line2.y2 = height;

		_line3.x = 0;
		_line3.y = 0;
		_line3.x2 = 0;
		_line3.y2 = height;

		_line4.x = width;
		_line4.y = 0;
		_line4.x2 = width;
		_line4.y2 = height;
	}

	override private function updateArea():Void {
		area = 0;
		for (line in zones) {
			area += line.getArea();
		}
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "RectContour";
	}

	override public function toXML():Xml {
		var xml:Xml = cast super.toXML();

		xml.remove("zones");

		xml.set("virtualThickness", Std.string(virtualThickness));
		xml.set("x", Std.string(_x));
		xml.set("y", Std.string(_y));
		xml.set("width", Std.string(width));
		xml.set("height", Std.string(height));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);
		// parsing removes all zones, so we add them back
		addZone(_line1);
		addZone(_line2);
		addZone(_line3);
		addZone(_line4);
		if (xml.exists("virtualThickness"))
			virtualThickness = Std.parseFloat(xml.get("virtualThickness"));
		if (xml.exists("x"))
			x = Std.parseFloat(xml.get("x"));
		if (xml.exists("y"))
			y = Std.parseFloat(xml.get("y"));
		if (xml.exists("width"))
			width = Std.parseFloat(xml.get("width"));
		if (xml.exists("height"))
			height = Std.parseFloat(xml.get("height"));
	}
}
