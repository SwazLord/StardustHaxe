package idv.cjcat.stardustextended.easing;

/**
 *  Easing Equations
 *  <p>(c) 2003 Robert Penner, all rights reserved.</p>
 *  <p>This work is subject to the terms in http://www.robertpenner.com/easing_terms_of_use.html.</p>
 */
class Circ {
	inline public static function easeIn(t:Float, b:Float, c:Float, d:Float):Float {
		return -c * (Math.sqrt(1 - (t /= d) * t) - 1) + b;
	}

	inline public static function easeOut(t:Float, b:Float, c:Float, d:Float):Float {
		return c * Math.sqrt(1 - (t = t / d - 1) * t) + b;
	}

	inline public static function easeInOut(t:Float, b:Float, c:Float, d:Float):Float {
		if ((t /= d / 2) < 1) {
			return -c / 2 * (Math.sqrt(1 - t * t) - 1) + b;
		}
		return c / 2 * (Math.sqrt(1 - (t -= 2) * t) + 1) + b;
	}

	public function new() {}
}
