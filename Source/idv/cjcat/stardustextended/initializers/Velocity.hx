package idv.cjcat.stardustextended.initializers;

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.actions.IZoneContainer;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;
import idv.cjcat.stardustextended.zones.SinglePoint;
import idv.cjcat.stardustextended.zones.Zone;
import idv.cjcat.stardustextended.zones.ZoneCollection;

/**
 * Sets a particle's velocity based on the <code>zone</code> property.
 *
 * <p>
 * A particle's velocity is determined by a random point in the zone.
 * (The vector pointing from the origin to the random point).
 * </p>
 */
class Velocity extends Initializer implements IZoneContainer {
	public var zones(get, set):Array<Zone>;

	private var zoneCollection:ZoneCollection;

	private function get_zones():Array<Zone> {
		return zoneCollection.zones;
	}

	private function set_zones(value:Array<Zone>):Array<Zone> {
		zoneCollection.zones = value;
		return value;
	}

	public function new(zones:Array<Zone> = null) {
		super();
		zoneCollection = new ZoneCollection();
		if (zones != null) {
			zoneCollection.zones = zones;
		} else {
			zoneCollection.zones.push(new SinglePoint(0, 0));
		}
	}

	override public function initialize(particle:Particle):Void {
		var md2D:MotionData2D = zoneCollection.getRandomPointInZones();
		if (md2D != null) {
			particle.vx += md2D.x;
			particle.vy += md2D.y;
			MotionData2DPool.recycle(md2D);
		}
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getRelatedObjects():Array<StardustElement> {
		return zoneCollection.zones;
	}

	override public function getXMLTagName():String {
		return "Velocity";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();
		zoneCollection.addToStardustXML(xml);
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
	}
}
