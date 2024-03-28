package idv.cjcat.stardustextended.events;

import openfl.events.Event;
import idv.cjcat.stardustextended.actions.Action;

class StardustActionEvent extends Event {
	public var action(get, set):Action;

	public static inline var PRIORITY_CHANGE:String = "PRIORITY_CHANGE";
	public static inline var ADD:String = "ADD";
	public static inline var REMOVE:String = "REMOVE";

	private var _action:Action;

	public function new(_type:String) {
		super(_type);
	}

	private function set_action(a:Action):Action {
		_action = a;
		return a;
	}

	private function get_action():Action {
		return _action;
	}

	override public function clone():Event {
		var copy:StardustActionEvent = new StardustActionEvent(type);
		copy.action = _action;

		return copy;
	}
}
