package idv.cjcat.stardustextended.deflectors;

import openfl.geom.Point;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.MotionData4D;
import idv.cjcat.stardustextended.geom.MotionData4DPool;

/**
 * Causes particles to be bounded within a rectangular region.
 *
 * <p>
 * When a particle hits the walls of the region, it bounces back.
 * </p>
 */
class BoundingBox extends Deflector {
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
		this.bounce = 1;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	private var radius:Float;
	private var left:Float;
	private var right:Float;
	private var top:Float;
	private var bottom:Float;
	private var factor:Float;
	private var finalX:Float;
	private var finalY:Float;
	private var finalVX:Float;
	private var finalVY:Float;
	private var deflected:Bool;

	override private function calculateMotionData4D(particle:Particle):MotionData4D {
		radius = particle.collisionRadius * particle.scale;
		left = x + radius;
		right = x + width - radius;
		top = y + radius;
		bottom = y + height - radius;

		factor = -bounce;

		finalX = particle.x;
		finalY = particle.y;
		finalVX = particle.vx;
		finalVY = particle.vy;

		deflected = false;
		if (particle.x <= left) {
			finalX = left;
			finalVX *= factor;
			deflected = true;
		} else if (particle.x >= right) {
			finalX = right;
			finalVX *= factor;
			deflected = true;
		}
		if (particle.y <= top) {
			finalY = top;
			finalVY *= factor;
			deflected = true;
		} else if (particle.y >= bottom) {
			finalY = bottom;
			finalVY *= factor;
			deflected = true;
		}

		if (deflected) {
			return MotionData4DPool.get(finalX, finalY, finalVX, finalVY);
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
		return "BoundingBox";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

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
			width = Std.parseFloat(xml.get("y"));
		}
		if (xml.exists("height")) {
			height = Std.parseFloat(xml.get("height"));
		}
	}
}
