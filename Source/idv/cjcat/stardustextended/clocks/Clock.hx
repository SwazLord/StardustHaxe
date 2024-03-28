package idv.cjcat.stardustextended.clocks;

import idv.cjcat.stardustextended.StardustElement;

/**
 * A clock is used by an emitter to determine how frequently particles are created.
 *
 * @see idv.cjcat.stardustextended.emitters.Emitter
 */
class Clock extends StardustElement {
	public function new() {
		super();
	}

	/**
	 * [Template Method] On each <code>Emitter.step()</code> call, this method is called.
	 *
	 * The returned value tells the emitter how many particles it should create.
	 *
	 * @param time The timespan the emitter emitter's step.
	 * @return
	 */
	public function getTicks(time:Float):Int {
		return 0;
	}

	public function reset():Void { // override it if needed
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getElementTypeXMLTag():Xml {
		return Xml.parse("<clocks/>");
	}
}
