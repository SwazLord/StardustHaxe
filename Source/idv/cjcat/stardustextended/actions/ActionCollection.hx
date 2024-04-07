package idv.cjcat.stardustextended.actions;

import openfl.Vector;
import idv.cjcat.stardustextended.events.StardustActionEvent;

/**
 * This class is used internally by classes that implements the <code>ActionCollector</code> interface.
 */
class ActionCollection implements ActionCollector {
	public var actions(get, never):Vector<Action>;

	private var _actions:Vector<Action>;

	public function new() {
		_actions = new Vector<Action>();
	}

	inline final private function get_actions():Vector<Action> {
		return _actions;
	}

	final public function addAction(action:Action):Void {
		if (Lambda.indexOf(_actions, action) >= 0) {
			return;
		}
		_actions.push(action);
		action.addEventListener(StardustActionEvent.PRIORITY_CHANGE, sortActions);
		sortActions();
	}

	final public function removeAction(action:Action):Void {
		var index:Int;

		if ((index = Lambda.indexOf(_actions, action)) >= 0) {
			_actions.splice(index, 1)[0];
			action.removeEventListener(StardustActionEvent.PRIORITY_CHANGE, sortActions);
		}
	}

	final public function clearActions():Void {
		for (action in _actions) {
			removeAction(action);
		}
	}

	final public function sortActions(event:StardustActionEvent = null):Void {
		_actions.sort(prioritySort);
	}

	// descending priority sort
	private static function prioritySort(el1:Action, el2:Action):Int {
		if (el1.priority > el2.priority) {
			return -1;
		} else if (el1.priority < el2.priority) {
			return 1;
		}

		return 0;
	}
}
