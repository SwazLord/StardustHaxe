package idv.cjcat.stardustextended.initializers;

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
	public var zones(get, set):Array<Zone>;
	public var currentPosition(get, never):Point;

	private var zoneCollection:ZoneCollection;

	private function get_zones():Array<Zone> {
		return zoneCollection.zones;
	}

	private function set_zones(value:Array<Zone>):Array<Zone> {
		zoneCollection.zones = value;
		return value;
	}

	public var inheritVelocity:Bool = false;
	public var positions:Array<Point>;

	private var prevPos:Int;
	private var currentPos:Int;

	public function new(zones:Array<Zone> = null) {
		super();
		zoneCollection = new ZoneCollection();
		if (zones != null) {
			zoneCollection.zones = zones;
		} else {
			zoneCollection.zones.push(new RectZone());
		}
	}

	override public function doInitialize(particles:Array<Particle>, currentTime:Float):Void {
		if (positions != null) {
			currentPos = as3hx.Compat.parseInt(currentTime % positions.length);
			prevPos = ((currentPos > 0)) ? currentPos - 1 : positions.length - 1;
		}
		super.doInitialize(particles, currentTime);
	}

	override public function initialize(particle:Particle):Void {
		var md2D:MotionData2D = zoneCollection.getRandomPointInZones();
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

	private function get_currentPosition():Point {
		if (positions != null) {
			return positions[currentPos];
		}
		return null;
	}

	// Xml
	//------------------------------------------------------------------------------------------------
	override public function getRelatedObjects():Array<StardustElement> {
		return zoneCollection.zones;
	}

	override public function getXMLTagName():String {
		return "PositionAnimated";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();
		zoneCollection.addToStardustXML(xml);
		xml.setAttribute("inheritVelocity", inheritVelocity);
		if (positions != null && positions.length > 0) {
			registerClassAlias("String", String);
			registerClassAlias("Point", Point);
			registerClassAlias("VecPoint", Type.getClass(Array /*Vector.<T> call?*/));
			var ba:ByteArray = new ByteArray();
			ba.writeObject(positions);
			xml.setAttribute("positions", Base64.encode(ba));
		}
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.att.zone.length()) {
			trace("WARNING: the simulation contains a deprecated property 'zone' for " + getXMLTagName());
			zoneCollection.zones = [cast((builder.getElementByName(xml.att.zone)), Zone)];
		} else {
			zoneCollection.parseFromStardustXML(xml, builder);
		}
		if (xml.att.positions.length()) {
			registerClassAlias("String", String);
			registerClassAlias("Point", Point);
			registerClassAlias("VecPoint", Type.getClass(Array /*Vector.<T> call?*/));
			var ba:ByteArray = Base64.decode(xml.att.positions);
			ba.position = 0;
			positions = ba.readObject();
		}
		if (xml.att.inheritVelocity.length()) {
			inheritVelocity = (xml.att.inheritVelocity == "true");
		}
	}
}
