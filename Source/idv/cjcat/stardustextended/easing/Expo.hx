package idv.cjcat.stardustextended.easing;

/**
 *  Easing Equations
 *  <p>(c) 2003 Robert Penner, all rights reserved.</p>
 *  <p>This work is subject to the terms in http://www.robertpenner.com/easing_terms_of_use.html.</p>
 */
class Expo {
	inline public static function easeIn(t:Float, b:Float, c:Float, d:Float):Float {
		return ((t == 0)) ? b : c * Math.pow(2, 10 * (t / d - 1)) + b;
	}

	inline public static function easeOut(t:Float, b:Float, c:Float, d:Float):Float {
		return ((t == d)) ? b + c : c * (-Math.pow(2, -10 * t / d) + 1) + b;
	}

	inline public static function easeInOut(t:Float, b:Float, c:Float, d:Float):Float {
		if (t == 0) {
			return b;
		}
		if (t == d) {
			return b + c;
		}
		if ((t /= d / 2) < 1) {
			return c / 2 * Math.pow(2, 10 * (t - 1)) + b;
		}
		return c / 2 * (-Math.pow(2, -10 * --t) + 2) + b;
	}

	public function new() {}
}
