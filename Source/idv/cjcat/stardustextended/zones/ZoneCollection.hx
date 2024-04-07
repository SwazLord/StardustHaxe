package idv.cjcat.stardustextended.zones;

import openfl.Vector;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.MotionData2D;

class ZoneCollection {
	public var zones:Vector<Zone> = new Vector<Zone>();

	public function new():Void {}

	inline public final function getRandomPointInZones():MotionData2D {
		var md2D:MotionData2D = new MotionData2D(0, 0);
		var numZones:UInt = zones.length;
		if (numZones > 1) {
			var sumArea:Float = 0;
			var areas:Vector<Float> = new Vector<Float>();
			for (i in 0...numZones) {
				sumArea += cast(zones[i], Zone).getArea();
				areas.push(sumArea);
			}
			var position:Float = Math.random() * sumArea;
			for (i in 0...areas.length) {
				if (position <= areas[i]) {
					md2D = zones[i].getPoint();
					break;
				}
			}
		} else if (numZones == 1) {
			md2D = zones[0].getPoint();
		}
		return md2D; // returns null if there are no zones
	}

	inline public final function contains(xc:Float, yc:Float):Bool {
		var contains:Bool = false;
		for (zone in zones) {
			if (zone.contains(xc, yc)) {
				contains = true;
				break;
			}
		}
		return contains;
	}

	inline public final function addToStardustXML(stardustXML:Xml):Void {
		if (zones.length > 0) {
			var access = new haxe.xml.Access(stardustXML);
			// stardustXML.appendChild(<zones/>);
			// stardustXML.addChild(Xml.createElement("zones"));
			access.x.addChild(Xml.createElement("zones"));
			var zone:Zone;
			for (zone in zones) {
				// stardustXML.zones.appendChild(zone.getXMLTag());
				access.node.resolve("zones").x.addChild(zone.getXMLTag());
			}
		}
	}

	inline public final function parseFromStardustXML(stardustXML:Xml, builder:XMLBuilder):Void {
		zones = new Vector<Zone>();
		var access = new haxe.xml.Access(stardustXML);
		for (node in access.node.zones.elements) {
			zones.push(cast(builder.getElementByName(node.att.name), Zone));
		}
	}
}
