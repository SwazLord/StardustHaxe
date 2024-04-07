package idv.cjcat.stardustextended.geom;

import openfl.Vector;

class MotionData2DPool {
	private static var _recycled:Vector<MotionData2D> = new Vector<MotionData2D>();

	inline public static function get(x:Float = 0, y:Float = 0):MotionData2D {
		var obj:MotionData2D;

		if (_recycled.length > 0) {
			obj = _recycled.pop();
			obj.setTo(x, y);
		} else {
			obj = new MotionData2D(x, y);
		}

		return obj;
	}

	inline public static function recycle(obj:MotionData2D):Void {
		_recycled.push(obj);
	}

	public function new() {}
}
