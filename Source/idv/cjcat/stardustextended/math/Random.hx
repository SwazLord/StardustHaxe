package idv.cjcat.stardustextended.math;

import idv.cjcat.stardustextended.StardustElement;

/**
 * This class generates a random number.
 */
class Random extends StardustElement {
	/**
	 * [Abstract Method] Generates a random number.
	 * @return
	 */
	public function random():Float // abstract method
	{
		return 0.5;
	}

	/**
	 * [Abstract Method] Sets the random number's range.
	 * @param    lowerBound
	 * @param    upperBound
	 */
	public function setRange(lowerBound:Float, upperBound:Float):Void { // abstract method
	}

	/**
	 * [Abstract Method] Returns the random number's range.
	 * @return
	 */
	public function getRange():Array<Dynamic> // abstract method
	{
		return [0.5, 0.5];
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "Random";
	}

	override public function getElementTypeXMLTag():Xml {
		return Xml.parse("<randoms/>");
	}

	public function new() {
		super();
	}
}
