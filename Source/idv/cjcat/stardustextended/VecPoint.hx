package idv.cjcat.stardustextended;

class VecPoint<T> {
	private var _data:Array<T>;

	public function new() {
		_data = [];
	}

	public function push(item:T):Int {
		return _data.push(item);
	}

	public function get(index:Int):T {
		return _data[index];
	}

	public function set(index:Int, value:T):Void {
		_data[index] = value;
	}

	public function length():Int {
		return _data.length;
	}
}
