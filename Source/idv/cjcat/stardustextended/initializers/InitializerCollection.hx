package idv.cjcat.stardustextended.initializers;

import openfl.Vector;
import idv.cjcat.stardustextended.events.StardustInitializerEvent;

/**
 * This class is used internally by classes that implements the <code>InitializerCollector</code> interface.
 */
class InitializerCollection implements InitializerCollector {
	public var initializers(get, never):Vector<Initializer>;

	private var _initializers:Vector<Initializer>;

	public function new() {
		_initializers = new Vector<Initializer>();
	}

	final public function addInitializer(initializer:Initializer):Void {
		if (Lambda.indexOf(_initializers, initializer) >= 0) {
			return;
		}
		_initializers.push(initializer);
		initializer.addEventListener(StardustInitializerEvent.PRIORITY_CHANGE, sortInitializers);
		sortInitializers();
	}

	final public function removeInitializer(initializer:Initializer):Void {
		var index:Int;

		if ((index = Lambda.indexOf(_initializers, initializer)) >= 0) {
			_initializers.splice(index, 1)[0];
			initializer.removeEventListener(StardustInitializerEvent.PRIORITY_CHANGE, sortInitializers);
		}
	}

	final public function sortInitializers(event:StardustInitializerEvent = null):Void {
		_initializers.sort(prioritySort);
	}

	final public function clearInitializers():Void {
		for (initializer in _initializers) {
			removeInitializer(initializer);
		}
	}

	private function get_initializers():Vector<Initializer> {
		return _initializers;
	}

	// descending priority sort
	private static function prioritySort(el1:Initializer, el2:Initializer):Int {
		if (el1.priority > el2.priority) {
			return -1;
		} else if (el1.priority < el2.priority) {
			return 1;
		}
		return 0;
	}
}
