package idv.cjcat.stardustextended.deflectors;

import openfl.geom.Point;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.MotionData4D;
import idv.cjcat.stardustextended.geom.MotionData4DPool;

/**
 * Keeps particles inside a rectangular region.
 *
 * <p>
 * When a particle goes beyond a wall of the region, it reappears from the other side.
 * </p>
 */
class WrappingBox extends Deflector {
	/**
	 * The X coordinate of the top-left corner.
	 */
	public var x:Float;

	/**
	 * The Y coordinate of the top-left corner.
	 */
	public var y:Float;

	/**
	 * The width of the region.
	 */
	public var width:Float;

	/**
	 * The height of the region.
	 */
	public var height:Float;

	public function new(x:Float = 0, y:Float = 0, width:Float = 640, height:Float = 480) {
		super();
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	private var left:Float;
	private var right:Float;
	private var top:Float;
	private var bottom:Float;
	private var deflected:Bool;
	private var newX:Float;
	private var newY:Float;

	override private function calculateMotionData4D(particle:Particle):MotionData4D {
		left = x;
		right = x + width;
		top = y;
		bottom = y + height;

		deflected = false;
		if (particle.x < x) {
			deflected = true;
		} else if (particle.x > (x + width)) {
			deflected = true;
		}
		if (particle.y < y) {
			deflected = true;
		} else if (particle.y > (y + height)) {
			deflected = true;
		}

		newX = StardustMath.mod(particle.x - x, width);
		newY = StardustMath.mod(particle.y - y, height);

		if (deflected) {
			return MotionData4DPool.get(x + newX, y + newY, particle.vx, particle.vy);
		} else {
			return null;
		}
	}

	override public function setPosition(xc:Float, yc:Float):Void {
		x = xc;
		y = yc;
	}

	override public function getPosition():Point {
		position.setTo(x, y);
		return position;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "WrappingBox";
	}

	override public function toXML():Xml {
		var xml:Xml = cast super.toXML();

		xml.remove("bounce");

		xml.set("x", Std.string(x));
		xml.set("y", Std.string(y));
		xml.set("width", Std.string(width));
		xml.set("height", Std.string(height));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("x")) {
			x = Std.parseFloat(xml.get("x"));
		}
		if (xml.exists("y")) {
			y = Std.parseFloat(xml.get("y"));
		}
		if (xml.exists("width")) {
			width = Std.parseFloat(xml.get("width"));
		}
		if (xml.exists("height")) {
			height = Std.parseFloat(xml.get("height"));
		}
	}
}
