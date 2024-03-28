package idv.cjcat.stardustextended.zones;

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.geom.MotionData2DPool;
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;

/**
 * Rectangular zone.
 */
class RectZone extends Zone {
	public var width(get, set):Float;
	public var height(get, set):Float;
	public var randomX(get, set):Random;
	public var randomY(get, set):Random;

	private var _randomX:Random;
	private var _randomY:Random;
	private var _width:Float;
	private var _height:Float;

	public function new(x:Float = 0, y:Float = 0, width:Float = 150, height:Float = 50, randomX:Random = null, randomY:Random = null) {
		super();
		if (randomX == null) {
			randomX = new UniformRandom();
		}
		if (randomY == null) {
			randomY = new UniformRandom();
		}

		this._x = x;
		this._y = y;
		this.width = width;
		this.height = height;
		this.randomX = randomX;
		this.randomY = randomY;
	}

	private function get_width():Float {
		return _width;
	}

	private function set_width(value:Float):Float {
		_width = value;
		updateArea();
		return value;
	}

	private function get_height():Float {
		return _height;
	}

	private function set_height(value:Float):Float {
		_height = value;
		updateArea();
		return value;
	}

	private function get_randomX():Random {
		return _randomX;
	}

	private function set_randomX(value:Random):Random {
		if (value == null) {
			value = new UniformRandom();
		}
		_randomX = value;
		return value;
	}

	private function get_randomY():Random {
		return _randomY;
	}

	private function set_randomY(value:Random):Random {
		if (value == null) {
			value = new UniformRandom();
		}
		_randomY = value;
		return value;
	}

	override private function updateArea():Void {
		area = _width * _height;
	}

	override public function calculateMotionData2D():MotionData2D {
		_randomX.setRange(0, _width);
		_randomY.setRange(0, _height);
		return MotionData2DPool.get(_randomX.random(), _randomY.random());
	}

	override public function contains(xc:Float, yc:Float):Bool {
		if (_rotation != 0) {
			// rotate the point backwards instead, it has the same result{

			var vec:Vec2D = Vec2DPool.get(xc, yc);
			vec.rotate(-_rotation);
			xc = vec.x;
			yc = vec.y;
		}

		if ((xc < _x) || (xc > (_x + _width))) {
			return false;
		} else if ((yc < _y) || (yc > (_y + _height))) {
			return false;
		}

		return true;
	}

	// Xml
	//------------------------------------------------------------------------------------------------
	override public function getRelatedObjects():Array<StardustElement> {
		return [_randomX, _randomY];
	}

	override public function getXMLTagName():String {
		return "RectZone";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.setAttribute("x", _x);
		xml.setAttribute("y", _y);
		xml.setAttribute("width", _width);
		xml.setAttribute("height", _height);
		xml.setAttribute("randomX", _randomX.name);
		xml.setAttribute("randomY", _randomY.name);

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
		if (xml.att.width.length()) {
			width = as3hx.Compat.parseFloat(xml.att.width);
		}
		if (xml.att.height.length()) {
			height = as3hx.Compat.parseFloat(xml.att.height);
		}
		if (xml.att.randomX.length()) {
			randomX = try cast(builder.getElementByName(xml.att.randomX), Random) catch (e:Dynamic) null;
		}
		if (xml.att.randomY.length()) {
			randomY = try cast(builder.getElementByName(xml.att.randomY), Random) catch (e:Dynamic) null;
		}
	}
}
