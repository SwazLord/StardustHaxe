package idv.cjcat.stardustextended.easing;

/**
 *  Easing Equations
 *  <p>(c) 2003 Robert Penner, all rights reserved.</p>
 *  <p>This work is subject to the terms in http://www.robertpenner.com/easing_terms_of_use.html.</p>
 */
class Elastic {
	private static var _2PI:Float = Math.PI * 2;

	inline public static function easeIn(t:Float, b:Float, c:Float, d:Float, a:Float = 0, p:Float = 0):Float {
		var s:Float;
		if (t == 0) {
			return b;
		}
		if ((t /= d) == 1) {
			return b + c;
		}
		if (p != null) {
			p = d * .3;
		}
		if (a != null || a < Math.abs(c)) {
			a = c;
			s = p / 4;
		} else {
			s = p / _2PI * Math.asin(c / a);
		}
		return -(a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t * d - s) * _2PI / p)) + b;
	}

	inline public static function easeOut(t:Float, b:Float, c:Float, d:Float, a:Float = 0, p:Float = 0):Float {
		var s:Float;
		if (t == 0) {
			return b;
		}
		if ((t /= d) == 1) {
			return b + c;
		}
		if (p != null) {
			p = d * .3;
		}
		if (a != null || a < Math.abs(c)) {
			a = c;
			s = p / 4;
		} else {
			s = p / _2PI * Math.asin(c / a);
		}
		return (a * Math.pow(2, -10 * t) * Math.sin((t * d - s) * _2PI / p) + c + b);
	}

	inline public static function easeInOut(t:Float, b:Float, c:Float, d:Float, a:Float = 0, p:Float = 0):Float {
		var s:Float;
		if (t == 0) {
			return b;
		}
		if ((t /= d / 2) == 2) {
			return b + c;
		}
		if (p != null) {
			p = d * (.3 * 1.5);
		}
		if (a != null || a < Math.abs(c)) {
			a = c;
			s = p / 4;
		} else {
			s = p / _2PI * Math.asin(c / a);
		}
		if (t < 1) {
			return -.5 * (a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t * d - s) * _2PI / p)) + b;
		}
		return a * Math.pow(2, -10 * (t -= 1)) * Math.sin((t * d - s) * _2PI / p) * .5 + c + b;
	}

	public function new() {}
}
