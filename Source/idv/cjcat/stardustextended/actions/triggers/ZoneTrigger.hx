package idv.cjcat.stardustextended.actions.triggers;

import openfl.Vector;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.actions.IZoneContainer;
import idv.cjcat.stardustextended.zones.RectZone;
import idv.cjcat.stardustextended.zones.Zone;
import idv.cjcat.stardustextended.zones.ZoneCollection;

/**
 * This trigger is triggered when a particle is contained in a zone.
 */
class ZoneTrigger extends Trigger implements IZoneContainer {
	public var zones(get, set):Vector<Zone>;

	private var zoneCollection:ZoneCollection;

	private function get_zones():Vector<Zone> {
		return zoneCollection.zones;
	}

	private function set_zones(value:Vector<Zone>):Vector<Zone> {
		zoneCollection.zones = value;
		return value;
	}

	public function new(zones:Vector<Zone> = null) {
		super();
		zoneCollection = new ZoneCollection();
		if (zones != null) {
			zoneCollection.zones = zones;
		} else {
			zoneCollection.zones.push(new RectZone());
		}
	}

	override public function testTrigger(emitter:Emitter, particle:Particle, time:Float):Bool {
		return zoneCollection.contains(particle.x, particle.y);
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getRelatedObjects():Vector<StardustElement> {
		return cast zoneCollection.zones;
	}

	override public function getXMLTagName():String {
		return "ZoneTrigger";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();
		zoneCollection.addToStardustXML(xml);
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
	}
}
