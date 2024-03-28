package idv.cjcat.stardustextended.zones;

import idv.cjcat.stardustextended.geom.MotionData2DPool;
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.MotionData2D;

/**
 * Sector-shaped zone.
 */
class Sector extends Zone {
	public var minRadius(get, set):Float;
	public var maxRadius(get, set):Float;
	public var minAngle(get, set):Float;
	public var maxAngle(get, set):Float;

	private var _randomT:Random;
	private var _minRadius:Float;
	private var _maxRadius:Float;
	private var _minAngle:Float;
	private var _maxAngle:Float;
	private var _minAngleRad:Float;
	private var _maxAngleRad:Float;

	public function new(x:Float = 0, y:Float = 0, minRadius:Float = 0, maxRadius:Float = 100, minAngle:Float = 0, maxAngle:Float = 360) {
		super();
		_randomT = new UniformRandom();

		this._x = x;
		this._y = y;
		this._minRadius = minRadius;
		this._maxRadius = maxRadius;
		this._minAngle = minAngle;
		this._maxAngle = maxAngle;

		updateArea();
	}

	/**
	 * The minimum radius of the sector.
	 */
	private function get_minRadius():Float {
		return _minRadius;
	}

	private function set_minRadius(value:Float):Float {
		_minRadius = value;
		updateArea();
		return value;
	}

	/**
	 * The maximum radius of the sector.
	 */
	private function get_maxRadius():Float {
		return _maxRadius;
	}

	private function set_maxRadius(value:Float):Float {
		_maxRadius = value;
		updateArea();
		return value;
	}

	/**
	 * The minimum angle of the sector.
	 */
	private function get_minAngle():Float {
		return _minAngle;
	}

	private function set_minAngle(value:Float):Float {
		_minAngle = value;
		updateArea();
		return value;
	}

	/**
	 * The maximum angle of the sector.
	 */
	private function get_maxAngle():Float {
		return _maxAngle;
	}

	private function set_maxAngle(value:Float):Float {
		_maxAngle = value;
		updateArea();
		return value;
	}

	override public function calculateMotionData2D():MotionData2D {
		if (_maxRadius == 0) {
			return MotionData2DPool.get(_x, _y);
		}

		_randomT.setRange(_minAngleRad, _maxAngleRad);
		var theta:Float = _randomT.random();
		var r:Float = StardustMath.interpolate(0, _minRadius, 1, _maxRadius, Math.sqrt(Math.random()));

		return MotionData2DPool.get(r * Math.cos(theta), r * Math.sin(theta));
	}

	override private function updateArea():Void {
		_minAngleRad = _minAngle * StardustMath.DEGREE_TO_RADIAN;
		_maxAngleRad = _maxAngle * StardustMath.DEGREE_TO_RADIAN;
		if (Math.abs(_minAngleRad) > StardustMath.TWO_PI) {
			_minAngleRad = _minAngleRad % StardustMath.TWO_PI;
		}
		if (Math.abs(_maxAngleRad) > StardustMath.TWO_PI) {
			_maxAngleRad = _maxAngleRad % StardustMath.TWO_PI;
		}
		var dT:Float = _maxAngleRad - _minAngleRad;

		var dRSQ:Float = _minRadius * _minRadius - _maxRadius * _maxRadius;

		area = Math.abs(dRSQ * dT);
	}

	override public function contains(x:Float, y:Float):Bool {
		var dx:Float = this._x - x;
		var dy:Float = this._y - y;
		var squaredDistance:Float = dx * dx + dy * dy;
		var isInsideOuterCircle:Bool = (squaredDistance <= _maxRadius * _maxRadius);
		if (!isInsideOuterCircle) {
			return false;
		}
		var isInsideInnerCircle:Bool = (squaredDistance <= _minRadius * _minRadius);
		if (isInsideInnerCircle) {
			return false;
		}
		var angle:Float = Math.atan2(dy, dx) + Math.PI;
		// TODO: does not work for edge cases, e.g. when minAngle = -20 and maxAngle = 20
		if (angle > _maxAngleRad || angle < _minAngleRad) {
			return false;
		}
		return true;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "Sector";
	}

	override public function toXML():Xml {
		var xml:Xml = cast super.toXML();
		xml.set("x", Std.string(_x));
		xml.set("y", Std.string(_y));
		xml.set("minRadius", Std.string(minRadius));
		xml.set("maxRadius", Std.string(maxRadius));
		xml.set("minAngle", Std.string(minAngle));
		xml.set("maxAngle", Std.string(maxAngle));
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("x")) {
			_x = Std.parseFloat(xml.get("x"));
		}
		if (xml.exists("y")) {
			_y = Std.parseFloat(xml.get("x"));
		}
		if (xml.exists("minRadius")) {
			minRadius = Std.parseFloat(xml.get("minRadius"));
		}
		if (xml.exists("maxRadius")) {
			maxRadius = Std.parseFloat(xml.get("maxRadius"));
		}
		if (xml.exists("minAngle")) {
			minAngle = Std.parseFloat(xml.get("minAngle"));
		}
		if (xml.exists("maxAngle")) {
			maxAngle = Std.parseFloat(xml.get("maxAngle"));
		}
	}
}
