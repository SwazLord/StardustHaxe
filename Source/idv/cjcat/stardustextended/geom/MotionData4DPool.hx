package idv.cjcat.stardustextended.geom;

import openfl.Vector;

class MotionData4DPool {
	private static var _recycled:Vector<MotionData4D> = new Vector<MotionData4D>();

	inline public static function get(x:Float = 0, y:Float = 0, vx:Float = 0, vy:Float = 0):MotionData4D {
		var obj:MotionData4D;
		if (_recycled.length > 0) {
			obj = _recycled.pop();
			obj.x = x;
			obj.y = y;
			obj.vx = vx;
			obj.vy = vy;
		} else {
			obj = new MotionData4D(x, y, vx, vy);
		}
		return obj;
	}

	inline public static function recycle(obj:MotionData4D):Void {
		_recycled.push(obj);
	}

	public function new() {}
}
