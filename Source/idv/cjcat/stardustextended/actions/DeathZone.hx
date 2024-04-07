package idv.cjcat.stardustextended.actions;

import openfl.Vector;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.zones.RectZone;
import idv.cjcat.stardustextended.zones.Zone;
import idv.cjcat.stardustextended.zones.ZoneCollection;

/**
 * Causes particles to be marked dead when they are not contained inside a specified zone.
 *
 * <p>
 * Default priority = -6;
 * </p>
 */
class DeathZone extends Action implements IZoneContainer {
	public var zones(get, set):Vector<Zone>;

	/**
	 * If a particle leave this zone (<code>Zone.contains()</code> returns false), it will be marked dead.
	 */
	private var zoneCollection:ZoneCollection;

	private function get_zones():Vector<Zone> {
		return zoneCollection.zones;
	}

	private function set_zones(value:Vector<Zone>):Vector<Zone> {
		zoneCollection.zones = value;
		return value;
	}

	/**
	 * Inverts the zone region.
	 */
	public var inverted:Bool;

	public function new(zones:Vector<Zone> = null, inverted:Bool = false) {
		super();
		priority = -6;

		zoneCollection = new ZoneCollection();
		if (zones != null) {
			zoneCollection.zones = zones;
		} else {
			zoneCollection.zones.push(new RectZone());
		}
		this.inverted = inverted;
	}

	override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		var dead:Bool = zoneCollection.contains(particle.x, particle.y);
		if (inverted) {
			dead = !dead;
		}
		if (dead) {
			particle.isDead = true;
		}
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getRelatedObjects():Vector<StardustElement> {
		return cast zoneCollection.zones;
	}

	override public function getXMLTagName():String {
		return "DeathZone";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();
		zoneCollection.addToStardustXML(xml);
		xml.set("inverted", Std.string(inverted));
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);
		if (xml.exists("zone")) {
			trace("WARNING: the simulation contains a deprecated property 'zone' for " + getXMLTagName());
			zoneCollection.zones = cast(builder.getElementByName(xml.get("zone")));
		} else {
			zoneCollection.parseFromStardustXML(xml, builder);
		}
		if (xml.exists("inverted")) {
			inverted = (xml.get("inverted") == "true");
		}
	}
}
