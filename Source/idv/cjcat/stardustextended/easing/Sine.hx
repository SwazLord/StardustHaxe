package idv.cjcat.stardustextended.easing;

/**
 *  Easing Equations
 *  <p>(c) 2003 Robert Penner, all rights reserved.</p>
 *  <p>This work is subject to the terms in http://www.robertpenner.com/easing_terms_of_use.html.</p>
 */
class Sine {
	private static var _HALF_PI:Float = Math.PI / 2;

	inline public static function easeIn(t:Float, b:Float, c:Float, d:Float):Float {
		return -c * Math.cos(t / d * _HALF_PI) + c + b;
	}

	inline public static function easeOut(t:Float, b:Float, c:Float, d:Float):Float {
		return c * Math.sin(t / d * _HALF_PI) + b;
	}

	inline public static function easeInOut(t:Float, b:Float, c:Float, d:Float):Float {
		return -c / 2 * (Math.cos(Math.PI * t / d) - 1) + b;
	}

	public function new() {}
}
