package idv.cjcat.stardustextended.zones;

import openfl.Vector;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.MotionData2D;

/**
 * This is a group of zones.
 *
 * <p>
 * The <code>calculateMotionData2D()</code> method returns random points in these zones.
 * These points are more likely to be situated in zones with bigger area.
 * </p>
 */
class Composite extends Zone {
	public var zones(get, set):Vector<Zone>;

	private var zoneCollection:ZoneCollection;

	private function get_zones():Vector<Zone> {
		return zoneCollection.zones;
	}

	private function set_zones(value:Vector<Zone>):Vector<Zone> {
		zoneCollection.zones = value;
		return value;
	}

	public function new() {
		super();
		zoneCollection = new ZoneCollection();
	}

	override public function calculateMotionData2D():MotionData2D {
		return zoneCollection.getRandomPointInZones();
	}

	override public function contains(x:Float, y:Float):Bool {
		return zoneCollection.contains(x, y);
	}

	final public function addZone(zone:Zone):Void {
		zoneCollection.zones.push(zone);
	}

	final public function removeZone(zone:Zone):Void {
		var index:Int;

		while ((index = zoneCollection.zones.indexOf(zone)) >= 0) {
			zoneCollection.zones.removeAt(index);
		}
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getRelatedObjects():Vector<StardustElement> {
		return cast zoneCollection.zones;
	}

	override public function getXMLTagName():String {
		return "CompositeZone";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();
		zoneCollection.addToStardustXML(xml);
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);
		zoneCollection.zones = new Vector<Zone>();
		zoneCollection.parseFromStardustXML(xml, builder);
	}
}
