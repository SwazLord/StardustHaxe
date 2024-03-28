package idv.cjcat.stardustextended.geom;

/**
 * 2D vector value class.
 *
 * <p>
 * Unlike the <code>Vec2D</code> class,
 * the sole purpose of this class is to hold two numeric values (X and Y components).
 * It does not provide vector operations like the <code>Vec2D</code> class does.
 * </p>
 */
class MotionData2D {
	public var x:Float;
	public var y:Float;

	public function new(x:Float = 0, y:Float = 0) {
		this.x = x;
		this.y = y;
	}

	inline final public function setTo(xc:Float, yc:Float):Void {
		x = xc;
		y = yc;
	}
}
