package idv.cjcat.stardustextended.geom;

import openfl.geom.Point;
import idv.cjcat.stardustextended.math.StardustMath;

class Vec2D extends Point {
	public function new(?_x:Float = 0, ?_y:Float = 0) {
		super(_x, _y);
	}

	override public function clone():Point {
		return new Vec2D(x, y);
	}

	// public var length(get, never):Float;

	override public function get_length():Float {
		return Math.sqrt(x * x + y * y);
	}

	override public function set_length(value:Float):Float {
		if (x == 0 && y == 0)
			return 0;
		var factor:Float = value / get_length();
		x *= factor;
		y *= factor;
		return value;
	}

	@:inline override public function setTo(xc:Float, yc:Float):Void {
		x = xc;
		y = yc;
	}

	/**
	 * Dot product.
	 * @param    vector
	 * @return
	 */
	public function dot(vector:Vec2D):Float {
		return (x * vector.x) + (y * vector.y);
	}

	/**
	 * Vector projection.
	 * @param    target
	 * @return
	 */
	public function project(target:Vec2D):Vec2D {
		var temp:Vec2D = cast clone();
		temp.projectThis(target);
		return temp;
	}

	public function projectThis(target:Vec2D):Void {
		var temp:Vec2D = Vec2DPool.get(target.x, target.y);
		temp.set_length(1.0);
		temp.set_length(dot(temp));
		x = temp.x;
		y = temp.y;
		Vec2DPool.recycle(temp);
	}

	/**
	 * Rotates this vector.
	 * @param angle Angle in degrees or radians
	 * @param useRadian Whether the given angle is in radians.
	 * @return this vector
	 */
	public function rotate(angle:Float, useRadian:Bool = false):Vec2D {
		if (!useRadian)
			angle *= StardustMath.DEGREE_TO_RADIAN;
		var originalX:Float = x;
		x = originalX * Math.cos(angle) - y * Math.sin(angle);
		y = originalX * Math.sin(angle) + y * Math.cos(angle);
		return this;
	}

	/**
	 * The angle between the vector and the positive x axis in degrees.
	 */
	public var angle(get, set):Float;

	inline function get_angle():Float {
		return Math.atan2(y, x) * StardustMath.RADIAN_TO_DEGREE;
	}

	inline function set_angle(value:Float):Float {
		var originalLength:Float = length;
		var rad:Float = value * StardustMath.DEGREE_TO_RADIAN;
		x = originalLength * Math.cos(rad);
		y = originalLength * Math.sin(rad);
		return value;
	}
}
