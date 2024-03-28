package idv.cjcat.stardustextended.easing;

/**
 *  Easing Equations
 *  <p>(c) 2003 Robert Penner, all rights reserved.</p>
 *  <p>This work is subject to the terms in http://www.robertpenner.com/easing_terms_of_use.html.</p>
 */
class Quart {
	inline public static function easeIn(t:Float, b:Float, c:Float, d:Float):Float {
		return c * (t /= d) * t * t * t + b;
	}

	inline public static function easeOut(t:Float, b:Float, c:Float, d:Float):Float {
		return -c * ((t = t / d - 1) * t * t * t - 1) + b;
	}

	inline public static function easeInOut(t:Float, b:Float, c:Float, d:Float):Float {
		if ((t /= d / 2) < 1) {
			return c / 2 * t * t * t * t + b;
		}
		return -c / 2 * ((t -= 2) * t * t * t - 2) + b;
	}

	public function new() {}
}
