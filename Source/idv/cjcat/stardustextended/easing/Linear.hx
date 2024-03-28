package idv.cjcat.stardustextended.easing;

/**
 *  Easing Equations
 *  <p>(c) 2003 Robert Penner, all rights reserved.</p>
 *  <p>This work is subject to the terms in http://www.robertpenner.com/easing_terms_of_use.html.</p>
 */
class Linear {
	inline public static function easeNone(t:Float, b:Float, c:Float, d:Float):Float {
		return c * t / d + b;
	}

	inline public static function easeIn(t:Float, b:Float, c:Float, d:Float):Float {
		return c * t / d + b;
	}

	inline public static function easeOut(t:Float, b:Float, c:Float, d:Float):Float {
		return c * t / d + b;
	}

	inline public static function easeInOut(t:Float, b:Float, c:Float, d:Float):Float {
		return c * t / d + b;
	}

	public function new() {}
}
