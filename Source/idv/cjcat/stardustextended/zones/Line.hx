package idv.cjcat.stardustextended.zones;

import idv.cjcat.stardustextended.geom.MotionData2DPool;
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.MotionData2D;

/**
 * Line segment zone.
 */
class Line extends Contour {
	public var x2(get, set):Float;
	public var y2(get, set):Float;
	public var random(get, set):Random;

	override private function set_x(value:Float):Float {
		_x = value;
		updateArea();
		return value;
	}

	override private function set_y(value:Float):Float {
		_y = value;
		updateArea();
		return value;
	}

	private var _x2:Float;

	/**
	 * The X coordinate of the other end of the line.
	 */
	private function get_x2():Float {
		return _x2;
	}

	private function set_x2(value:Float):Float {
		_x2 = value;
		updateArea();
		return value;
	}

	private var _y2:Float;

	/**
	 * The Y coordinate of the other end of the line.
	 */
	private function get_y2():Float {
		return _y2;
	}

	private function set_y2(value:Float):Float {
		_y2 = value;
		updateArea();
		return value;
	}

	private var _random:Random;

	public function new(x1:Float = 0, y1:Float = 0, x2:Float = 0, y2:Float = 0, random:Random = null) {
		super();
		this._x = x1;
		this._y = y1;
		this._x2 = x2;
		this._y2 = y2;
		this.random = random;
		updateArea();
	}

	override public function setPosition(xc:Float, yc:Float):Void {
		var xDiff:Float = _x2 - _x;
		var yDiff:Float = _y2 - _y;
		_x = xc;
		_y = yc;
		_x2 = xc + xDiff;
		_y2 = yc + yDiff;
	}

	private function get_random():Random {
		return _random;
	}

	private function set_random(value:Random):Random {
		if (value == null) {
			value = new UniformRandom();
		}
		_random = value;
		return value;
	}

	override public function calculateMotionData2D():MotionData2D {
		_random.setRange(0, 1);
		var rand:Float = _random.random();
		return MotionData2DPool.get(StardustMath.interpolate(0, 0, 1, _x2 - _x, rand), StardustMath.interpolate(0, 0, 1, _y2 - _y, rand));
	}

	override public function contains(x:Float, y:Float):Bool {
		if ((x < _x) && (x < _x2)) {
			return false;
		}
		if ((x > _x) && (x > _x2)) {
			return false;
		}
		if (((x - _x) / (_x2 - _x)) == ((y - _y) / (_y2 - _y))) {
			return true;
		}
		return false;
	}

	override private function updateArea():Void {
		var dx:Float = _x - _x2;
		var dy:Float = _y - _y2;
		area = Math.sqrt(dx * dx + dy * dy) * virtualThickness;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "Line";
	}

	override public function toXML():Xml {
		var xml:Xml = cast super.toXML();

		xml.set("x1", Std.string(_x));
		xml.set("y1", Std.string(_y));
		xml.set("x2", Std.string(_x2));
		xml.set("y2", Std.string(_y2));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("x1")) {
			_x = Std.parseFloat(xml.get("x1"));
		}
		if (xml.exists("y1")) {
			_y = Std.parseFloat(xml.get("y1"));
		}
		if (xml.exists("x2")) {
			_x2 = Std.parseFloat(xml.get("x2"));
		}
		if (xml.exists("y2")) {
			_y2 = Std.parseFloat(xml.get("y2"));
		}
		updateArea();
	}
}
