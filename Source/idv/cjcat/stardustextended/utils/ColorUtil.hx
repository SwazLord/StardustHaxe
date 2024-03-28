package idv.cjcat.stardustextended.utils;

class ColorUtil {
	private static var inv255:Float = 1 / 255;

	/**
	 * Converts a color from numeric values to its uint value. Input values are in the [0,1] range.
	 */
	inline public static function rgbToHex(r:Float, g:Float, b:Float):Int {
		return Std.int((Std.int(r * 256) << 16) | (Std.int(g * 256) << 8) | Std.int(b * 256));
	}

	inline public static function extractRed(c:Int):Float {
		return (Std.int(c >> 16) & 0xFF) * inv255;
	}

	inline public static function extractGreen(c:Int):Float {
		return (Std.int(c >> 8) & 0xFF) * inv255;
	}

	inline public static function extractBlue(c:Int):Float {
		return (c & 0xFF) * inv255;
	}

	inline public static function extractAlpha32(c:Int):Float {
		return (Std.int(c >> 24) & 0xFF) * inv255;
	}

	public function new() {}
}
