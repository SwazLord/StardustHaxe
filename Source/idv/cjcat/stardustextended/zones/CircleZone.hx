package idv.cjcat.stardustextended.zones;

import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;

/**
 * Circular zone.
 */
class CircleZone extends Zone {
	public var radius(get, set):Float;

	private var _radius:Float;
	private var _radiusSQ:Float;

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
		_radiusSQ = value * value;
		updateArea();
		return value;
	}

	override public function calculateMotionData2D():MotionData2D {
		var theta:Float = StardustMath.TWO_PI * Math.random();
		var r:Float = _radius * Math.sqrt(Math.random());
		return MotionData2DPool.get(r * Math.cos(theta), r * Math.sin(theta));
	}

	override public function contains(x:Float, y:Float):Bool {
		var dx:Float = this._x - x;
		var dy:Float = this._y - y;
		return (((dx * dx + dy * dy) <= _radiusSQ)) ? (true) : (false);
	}

	override private function updateArea():Void {
		area = _radiusSQ * Math.PI;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "CircleZone";
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
