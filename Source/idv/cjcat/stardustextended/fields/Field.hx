package idv.cjcat.stardustextended.fields;

import openfl.errors.Error;
import openfl.geom.Point;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.interfaces.IPosition;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;

/**
 * 2D vector field.
 */
class Field extends StardustElement implements IPosition {
	public var active:Bool;
	public var massless:Bool;

	private var position(default, never):Point = new Point();

	public function new() {
		super();
		active = true;
		massless = true;
	}

	private var md2D:MotionData2D;
	private var mass_inv:Float;

	final public function getMotionData2D(particle:Particle):MotionData2D {
		if (!active) {
			return MotionData2DPool.get(0, 0);
		}

		md2D = calculateMotionData2D(particle);

		if (!massless) {
			mass_inv = 1 / particle.mass;
			md2D.x *= mass_inv;
			md2D.y *= mass_inv;
		}

		return md2D;
	}

	private function calculateMotionData2D(particle:Particle):MotionData2D {
		return null;
	}

	/**
	 * [Abstract Method] Sets the position of this Field.
	 */
	public function setPosition(xc:Float, yc:Float):Void {
		throw new Error("This method must be overridden by subclasses");
	}

	/**
	 * [Abstract Method] Gets the position of this Field.
	 */
	public function getPosition():Point {
		throw new Error("This method must be overridden by subclasses");
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "Field";
	}

	override public function getElementTypeXMLTag():Xml {
		return Xml.parse("<fields/>");
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("active", Std.string(active));
		xml.set("massless", Std.string(massless));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);
		if (xml.exists("active")) {
			active = (xml.get("active") == "true");
		}
		if (xml.exists("massless")) {
			massless = (xml.get("massless") == "true");
		}
	}
}
