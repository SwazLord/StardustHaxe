package idv.cjcat.stardustextended.events;

import openfl.events.Event;
import idv.cjcat.stardustextended.emitters.Emitter;

class StardustEmitterStepEndEvent extends Event {
	public var emitter(get, never):Emitter;

	public static inline var TYPE:String = "StardustEmitterStepEndEvent";

	private var _emitter:Emitter;

	public function new(emitter:Emitter) {
		super(TYPE);
		_emitter = emitter;
	}

	private function get_emitter():Emitter {
		return _emitter;
	}

	override public function clone():Event {
		return new StardustEmitterStepEndEvent(_emitter);
	}
}
