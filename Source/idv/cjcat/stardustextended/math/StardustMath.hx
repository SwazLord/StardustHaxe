package idv.cjcat.stardustextended.math;

/**
 * This class provides common mathematical constants and methods.
 */
class StardustMath {
	public static var TWO_PI:Float = 2 * Math.PI;
	public static var DEGREE_TO_RADIAN:Float = Math.PI / 180;
	public static var RADIAN_TO_DEGREE:Float = 180 / Math.PI;

	/**
	 * Clamps a value within bounds.
	 * @param    input
	 * @param    lowerBound
	 * @param    upperBound
	 * @return
	 */
	inline public static function clamp(input:Float, lowerBound:Float, upperBound:Float):Float {
		if (input < lowerBound) {
			return lowerBound;
		}
		if (input > upperBound) {
			return upperBound;
		}
		return input;
	}

	/**
	 * Interpolates linearly between two values.
	 * @param    x1
	 * @param    y1
	 * @param    x2
	 * @param    y2
	 * @param    x3
	 * @return
	 */
	inline public static function interpolate(x1:Float, y1:Float, x2:Float, y2:Float, x3:Float):Float {
		return y1 - ((y1 - y2) * (x1 - x3) / (x1 - x2));
	}

	/**
	 * The remainder of value1 divided by value2, negative value1 exception taken into account.
	 * Value2 must be positive.
	 * @param    value1
	 * @param    value2
	 */
	inline public static function mod(value1:Float, value2:Float):Float {
		var remainder:Float = value1 % value2;
		return ((remainder < 0)) ? (remainder + value2) : (remainder);
	}

	inline public static function randomFloor(num:Float):Int {
		var floor:Int = Std.int(num) | 0;
		return Std.int(floor + ((((num - floor) > Math.random())) ? 1 : 0));
	}

	public function new() {}
}
