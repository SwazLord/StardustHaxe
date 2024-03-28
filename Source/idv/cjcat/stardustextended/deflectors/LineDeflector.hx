package idv.cjcat.stardustextended.deflectors;

import openfl.geom.Point;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.MotionData4D;
import idv.cjcat.stardustextended.geom.MotionData4DPool;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;

/**
 * Infinitely long line-shaped obstacle.
 * One side of the line is free space, and the other side is "solid",
 * not allowing any particle to go through.
 * The line is defined by a point it passes through and its normal vector.
 *
 * <p>
 * When a particle hits the border, it bounces back.
 * </p>
 */
class LineDeflector extends Deflector {
	public var normal(get, never):Vec2D;

	/**
	 * The X coordinate of a point the border passes through.
	 */
	public var x:Float;

	/**
	 * The Y coordinate of a point the border passes through.
	 */
	public var y:Float;

	private var _normal:Vec2D;

	public function new(x:Float = 0, y:Float = 0, nx:Float = 0, ny:Float = -1) {
		super();
		this.x = x;
		this.y = y;
		_normal = Vec2DPool.get(nx, ny);
	}

	/**
	 * The normal of the border, pointing to the free space side.
	 */
	private function get_normal():Vec2D {
		return _normal;
	}

	private var r:Vec2D;
	private var dot:Float;
	private var radius:Float;
	private var dist:Float;
	private var v:Vec2D;
	private var factor:Float;

	override function calculateMotionData4D(particle:Particle):MotionData4D {
		// normal displacement
		r = Vec2DPool.get(particle.x - x, particle.y - y);
		r = r.project(_normal);

		dot = r.dot(_normal);
		radius = particle.collisionRadius * particle.scale;
		dist = r.length;

		if (dot > 0) {
			if (dist > radius) {
				// no collision detected
				Vec2DPool.recycle(r);
				return null;
			} else {
				r.length = radius - dist;
			}
		} else {
			// collision detected
			r.length = -(dist + radius);
		}

		v = Vec2DPool.get(particle.vx, particle.vy);
		v = v.project(_normal);

		factor = 1 + bounce;

		Vec2DPool.recycle(r);
		Vec2DPool.recycle(v);
		return MotionData4DPool.get(particle.x + r.x, particle.y + r.y, (particle.vx - v.x * factor) * slipperiness,
			(particle.vy - v.y * factor) * slipperiness);
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
		return "LineDeflector";
	}

	override public function toXML():Xml {
		var xml:Xml = cast super.toXML();
		xml.set("x", Std.string(x));
		xml.set("y", Std.string(y));
		xml.set("normalX", Std.string(_normal.x));
		xml.set("normalY", Std.string(_normal.y));
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
		if (xml.exists("normalX")) {
			_normal.x = Std.parseFloat(xml.get("normalX"));
		}
		if (xml.exists("normalY")) {
			_normal.y = Std.parseFloat(xml.get("normalY"));
		}
	}
}
