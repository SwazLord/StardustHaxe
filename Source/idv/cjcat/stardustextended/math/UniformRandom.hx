package idv.cjcat.stardustextended.math;

import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * This class generates uniformly distributed random numbers.
 */
class UniformRandom extends Random {
	/**
	 * The expected value of the random number.
	 */
	public var center:Float;

	/**
	 * The variation of the random number.
	 *
	 * <p>
	 * The range of the generated random number is [center - radius, center + radius].
	 * </p>
	 */
	public var radius:Float;

	public function new(center:Float = 0.5, radius:Float = 0) {
		super();
		this.center = center;
		this.radius = radius;
	}

	inline final override public function random():Float {
		if (radius != 0 && !Math.isNaN(radius)) {
			return radius * 2 * (Math.random() - 0.5) + center;
		} else {
			return center;
		}
	}

	override public function setRange(lowerBound:Float, upperBound:Float):Void {
		var diameter:Float = upperBound - lowerBound;
		radius = 0.5 * diameter;
		center = lowerBound + radius;
	}

	override public function getRange():Array<Dynamic> {
		return [center - radius, center + radius];
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "UniformRandom";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("center", Std.string(center));
		xml.set("radius", Std.string(radius));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("center")) {
			center = Std.parseFloat(xml.get("center"));
		}
		if (xml.exists("radius")) {
			radius = Std.parseFloat(xml.get("radius"));
		}
	}
}
