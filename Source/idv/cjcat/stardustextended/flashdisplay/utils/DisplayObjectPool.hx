package idv.cjcat.stardustextended.flashdisplay.utils;

import openfl.display.DisplayObject;
import idv.cjcat.stardustextended.flashdisplay.utils.Construct;

class DisplayObjectPool {
	private static var DEFAULT_SIZE:Int = 32;

	private var _class:Class<Dynamic>;
	private var _params:Array<Dynamic>;
	private var _vec:Array<Dynamic> = [];
	private var _position:Int = 0;

	public function new() {}

	inline final public function reset(c:Class<Dynamic>, params:Array<Dynamic>):Void {
		_position = 0;
		// _vec = new Array<Dynamic>(DEFAULT_SIZE); // not required in Haxe
		_class = c;
		_params = params;
		for (i in 0...DEFAULT_SIZE) {
			_vec[i] = Construct.construct(_class, _params);
		}
	}

	inline final public function get():DisplayObject {
		if (_position == _vec.length) {
			_vec.resize(_vec.length << 1);
			for (i in _position..._vec.length) {
				_vec[i] = Construct.construct(_class, _params);
			}
		}
		_position++;
		return _vec[_position - 1];
	}

	inline final public function recycle(obj:DisplayObject):Void {
		if (_position == 0) {
			return;
		}
		if (obj == null) {
			return;
		}

		_vec[_position - 1] = obj;
		_position--;
		if (_position < 0) {
			_position = 0;
		}

		if (_vec.length > DEFAULT_SIZE * 2) {
			if (_position < (_vec.length >> 4)) {
				_vec.resize(_vec.length >> 1);
			}
		}
	}
}
