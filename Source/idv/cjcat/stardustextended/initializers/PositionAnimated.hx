package idv.cjcat.stardustextended.initializers;

import openfl.utils.ByteArray;
import openfl.geom.Point;
import haxe.Serializer;
import haxe.Unserializer;
import openfl.Vector;
import openfl.Lib;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.actions.IZoneContainer;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;
import idv.cjcat.stardustextended.utils.Base64;
import idv.cjcat.stardustextended.zones.RectZone;
import idv.cjcat.stardustextended.zones.Zone;
import idv.cjcat.stardustextended.zones.ZoneCollection;

/**
 * Sets a particle's initial position based on the zone plus on a value in the positions array.
 * The current position is: positions[currentFrame] + random point in the zone.
 */
class PositionAnimated extends Initializer implements IZoneContainer {
	private var zoneCollection:ZoneCollection;

	public var zones(get, set):Vector<Zone>;

	private function get_zones():Vector<Zone> {
		return zoneCollection.zones;
	}

	private function set_zones(value:Vector<Zone>):Vector<Zone> {
		zoneCollection.zones = value;
		return value;
	}

	public var inheritVelocity:Bool = false;
	public var positions:Vector<Point>;

	private var prevPos:UInt;
	private var currentPos:UInt;

	public function new(zones:Vector<Zone> = null) {
		super();
		zoneCollection = new ZoneCollection();
		if (zones != null) {
			zoneCollection.zones = zones;
		} else {
			zoneCollection.zones.push(new RectZone());
		}
	}

	override public function doInitialize(particles:Vector<Particle>, currentTime:Float):Void {
		if (positions != null) {
			currentPos = Std.int(currentTime) % positions.length;
			prevPos = (currentPos > 0) ? currentPos - 1 : positions.length - 1;
		}
		super.doInitialize(particles, currentTime);
	}

	override public function initialize(particle:Particle):Void {
		var md2D:MotionData2D = new MotionData2D(0, 0);
		md2D = zoneCollection.getRandomPointInZones();
		if (md2D != null) {
			particle.x = md2D.x;
			particle.y = md2D.y;

			if (positions != null) {
				particle.x = md2D.x + positions[currentPos].x;
				particle.y = md2D.y + positions[currentPos].y;

				if (inheritVelocity) {
					particle.vx += positions[currentPos].x - positions[prevPos].x;
					particle.vy += positions[currentPos].y - positions[prevPos].y;
				}
			} else {
				particle.x = md2D.x;
				particle.y = md2D.y;
			}
			MotionData2DPool.recycle(md2D);
		}
	}

	public function get_currentPosition():Point {
		if (positions != null) {
			return positions[currentPos];
		}
		return null;
	}

	// XML
	// ------------------------------------------------------------------------------------------------
	override public function getRelatedObjects():Vector<StardustElement> {
		return cast zoneCollection.zones;
	}

	override public function getXMLTagName():String {
		return "PositionAnimated";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();
		zoneCollection.addToStardustXML(xml);
		xml.set("inheritVelocity", Std.string(inheritVelocity));
		if (positions != null && positions.length > 0) {
			Lib.registerClassAlias("String", String);
			Lib.registerClassAlias("Point", Point);
			Lib.registerClassAlias("VecPoint", VecPoint);
			var bytes = new ByteArray();
			bytes.writeObject(positions);
			xml.set("positions", Base64.encode(bytes));
		}
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("zone")) {
			trace("WARNING: the simulation contains a deprecated property 'zone' for " + getXMLTagName());
			zoneCollection.zones = cast builder.getElementByName(xml.get("zone"));
		} else {
			zoneCollection.parseFromStardustXML(xml, builder);
		}
		if (xml.exists("positions")) {
			Lib.registerClassAlias("String", String);
			Lib.registerClassAlias("Point", Point);
			Lib.registerClassAlias("VecPoint", VecPoint);
			var bytes = new ByteArray();
			bytes = Base64.decode(xml.get("positions"));
			bytes.position = 0;
			positions = bytes.readObject();
		}
		if (xml.exists("inheritVelocity")) {
			inheritVelocity = xml.get("inheritVelocity") == "true";
		}
	}
}
