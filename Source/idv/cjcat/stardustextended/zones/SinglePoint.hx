package idv.cjcat.stardustextended.zones;

import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;

/**
 * Single point zone.
 */
class SinglePoint extends Contour {
	public function new(x:Float = 0, y:Float = 0) {
		super();
		_x = x;
		_y = y;
		updateArea();
	}

	override public function contains(x:Float, y:Float):Bool {
		if ((_x == x) && (_y == y)) {
			return true;
		}
		return false;
	}

	override public function calculateMotionData2D():MotionData2D {
		return MotionData2DPool.get(0, 0);
	}

	override private function updateArea():Void {
		area = virtualThickness * virtualThickness * Math.PI;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "SinglePoint";
	}

	override public function toXML():Xml {
		var xml:Xml = cast super.toXML();
		xml.set("x", Std.string(_x));
		xml.set("y", Std.string(_y));
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
	}
}
