package idv.cjcat.stardustextended.easing;

/**
 *  Easing Equations
 *  <p>(c) 2003 Robert Penner, all rights reserved.</p>
 *  <p>This work is subject to the terms in http://www.robertpenner.com/easing_terms_of_use.html.</p>
 */
class Bounce {
	inline public static function easeOut(t:Float, b:Float, c:Float, d:Float):Float {
		if ((t /= d) < (1 / 2.75)) {
			return c * (7.5625 * t * t) + b;
		} else if (t < (2 / 2.75)) {
			return c * (7.5625 * (t -= (1.5 / 2.75)) * t + .75) + b;
		} else if (t < (2.5 / 2.75)) {
			return c * (7.5625 * (t -= (2.25 / 2.75)) * t + .9375) + b;
		} else {
			return c * (7.5625 * (t -= (2.625 / 2.75)) * t + .984375) + b;
		}
	}

	inline public static function easeIn(t:Float, b:Float, c:Float, d:Float):Float {
		return c - easeOut(d - t, 0, c, d) + b;
	}

	inline public static function easeInOut(t:Float, b:Float, c:Float, d:Float):Float {
		if (t < d / 2) {
			return easeIn(t * 2, 0, c, d) * .5 + b;
		} else {
			return easeOut(t * 2 - d, 0, c, d) * .5 + c * .5 + b;
		}
	}

	public function new() {}
}
