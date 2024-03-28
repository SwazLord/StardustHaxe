package idv.cjcat.stardustextended.deflectors;

import openfl.errors.Error;
import openfl.geom.Point;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.interfaces.IPosition;
import idv.cjcat.stardustextended.geom.MotionData4D;

/**
 * Used along with the <code>Deflect</code> action.
 *
 * @see idv.cjcat.stardustextended.actions.Deflect
 */
class Deflector extends StardustElement implements IPosition {
	public var active:Bool;
	public var bounce:Float;

	private var position(default, never):Point = new Point();

	/**
	 * Determines how slippery the surfaces are. A value of 1 (default) means that the surface is fully slippery,
	 * a value of 0 means that particles will not slide on its surface at all.
	 */
	public var slipperiness:Float;

	public function new() {
		super();
		active = true;
		bounce = 0.8;
		slipperiness = 1;
	}

	final public function getMotionData4D(particle:Particle):MotionData4D {
		if (active) {
			return calculateMotionData4D(particle);
		}
		return null;
	}

	/**
	 * [Abstract Method] Returns a <code>MotionData4D</code> object representing the deflected position and velocity coordinates for a particle.
	 * Returns null if no deflection occurred. A non-null value can trigger the <code>DeflectorTrigger</code> action trigger.
	 * @param    particle
	 * @return
	 * @see idv.cjcat.stardustextended.actions.triggers.DeflectorTrigger
	 */
	private function calculateMotionData4D(particle:Particle):MotionData4D // abstract method
	{
		return null;
	}

	/**
	 * [Abstract Method] Sets the position of this Deflector.
	 */
	public function setPosition(xc:Float, yc:Float):Void {
		throw new Error("This method must be overridden by subclasses");
	}

	/**
	 * [Abstract Method] Gets the position of this Deflector.
	 */
	public function getPosition():Point {
		throw new Error("This method must be overridden by subclasses");
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "Deflector";
	}

	override public function getElementTypeXMLTag():Xml {
		return Xml.parse("<deflectors/>");
	}

	override public function toXML():Xml {
		var xml:Xml = cast super.toXML();
		xml.set("active", Std.string(active));
		xml.set("bounce", Std.string(bounce));
		xml.set("slipperiness", Std.string(slipperiness));
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("active")) {
			active = (xml.get("active") == "true");
		}

		if (xml.exists("bounce")) {
			bounce = Std.parseFloat(xml.get("bounce"));
		}

		if (xml.exists("slipperiness")) {
			slipperiness = Std.parseFloat(xml.get("slipperiness"));
		}
	}
}
