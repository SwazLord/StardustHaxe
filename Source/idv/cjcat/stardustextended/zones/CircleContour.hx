package idv.cjcat.stardustextended.zones;

import idv.cjcat.stardustextended.geom.MotionData2DPool;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.MotionData2D;

/**
 * Circular contour zone.
 */
class CircleContour extends Contour {
	public var radius(get, set):Float;

	private var _radius:Float;
	private var _r1SQ:Float;
	private var _r2SQ:Float;

	public function new(x:Float = 0, y:Float = 0, radius:Float = 100) {
		super();
		this._x = x;
		this._y = y;
		this.radius = radius;
	}

	/**
	 * The radius of the zone.
	 */
	private function get_radius():Float {
		return _radius;
	}

	private function set_radius(value:Float):Float {
		_radius = value;
		var r1:Float = value + 0.5 * virtualThickness;
		var r2:Float = value - 0.5 * virtualThickness;
		_r1SQ = r1 * r1;
		_r2SQ = r2 * r2;
		updateArea();
		return value;
	}

	override private function updateArea():Void {
		area = (_r1SQ - _r2SQ) * Math.PI * virtualThickness;
	}

	override public function contains(xc:Float, yc:Float):Bool {
		var dx:Float = _x - xc;
		var dy:Float = _y - yc;
		var dSQ:Float = dx * dx + dy * dy;
		return !((dSQ > _r1SQ) || (dSQ < _r2SQ));
	}

	override public function calculateMotionData2D():MotionData2D {
		var theta:Float = StardustMath.TWO_PI * Math.random();
		return MotionData2DPool.get(_radius * Math.cos(theta), _radius * Math.sin(theta));
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "CircleContour";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();
		xml.set("x", Std.string(_x));
		xml.set("y", Std.string(_y));
		xml.set("radius", Std.string(radius));
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("x")) {
			_x = Std.parseFloat(xml.get("x"));
		}
		if (xml.exists("y")) {
			_y = Std.parseFloat(xml.get("y"));
		}
		if (xml.exists("radius")) {
			radius = Std.parseFloat(xml.get("radius"));
		}
	}
}
