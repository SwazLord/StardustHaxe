package idv.cjcat.stardustextended.geom;

import openfl.Vector;

class Vec2DPool {
	private static var _recycled:Vector<Vec2D> = new Vector<Vec2D>();

	inline public static function get(x:Float = 0, y:Float = 0):Vec2D {
		var obj:Vec2D;

		if (_recycled.length > 0) {
			obj = _recycled.pop();
			obj.setTo(x, y);
		} else {
			obj = new Vec2D(x, y);
		}

		return obj;
	}

	inline public static function recycle(obj:Vec2D):Void {
		_recycled.push(obj);
	}

	public function new() {}
}
