package idv.cjcat.stardustextended.events;

import openfl.events.Event;
import idv.cjcat.stardustextended.initializers.Initializer;

class StardustInitializerEvent extends Event {
	public var initializer(get, set):Initializer;

	public static inline var PRIORITY_CHANGE:String = "PRIORITY_CHANGE";
	public static inline var ADD:String = "ADD";
	public static inline var REMOVE:String = "REMOVE";

	private var _initializer:Initializer;

	public function new(_type:String) {
		super(_type);
	}

	private function set_initializer(action:Initializer):Initializer {
		_initializer = action;
		return action;
	}

	private function get_initializer():Initializer {
		return _initializer;
	}

	override public function clone():Event {
		var copy:StardustInitializerEvent = new StardustInitializerEvent(type);
		copy.initializer = _initializer;

		return copy;
	}
}
