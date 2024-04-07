package idv.cjcat.stardustextended.deflectors;

import openfl.geom.Point;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.MotionData4D;
import idv.cjcat.stardustextended.geom.MotionData4DPool;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;

/**
 * Causes particles to be bounded within a circular region.
 *
 * <p>
 * When a particle hits the walls of the region, it bounces back.
 * </p>
 */
class BoundingCircle extends Deflector {
	/**
	 * The X coordinate of the center of the region.
	 */
	public var x:Float;

	/**
	 * The Y coordinate of the center of the region.
	 */
	public var y:Float;

	/**
	 * The radius of the region.
	 */
	public var radius:Float;

	public function new(x:Float = 0, y:Float = 0, radius:Float = 100) {
		super();
		this.bounce = 1;
		this.x = x;
		this.y = y;
		this.radius = radius;
	}

	private var cr:Float;
	private var r:Vec2D;
	private var len:Float;
	private var v:Vec2D;
	private var factor:Float;

	override private function calculateMotionData4D(particle:Particle):MotionData4D {
		cr = particle.collisionRadius * particle.scale;
		r = Vec2DPool.get(particle.x - x, particle.y - y);
		len = r.length + cr;
		if (len < radius) {
			Vec2DPool.recycle(r);
			return null;
		}

		r.length = radius - cr;

		v = Vec2DPool.get(particle.vx, particle.vy);
		v.projectThis(r);

		factor = 1 + bounce;

		Vec2DPool.recycle(r);
		Vec2DPool.recycle(v);

		return MotionData4DPool.get(x + r.x, y + r.y, particle.vx - factor * v.x, particle.vy - factor * v.y);
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
		return "BoundingCircle";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("x", Std.string(x));
		xml.set("y", Std.string(y));
		xml.set("radius", Std.string(radius));

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
		if (xml.exists("radius")) {
			radius = Std.parseFloat(xml.get("radius"));
		}
	}
}
