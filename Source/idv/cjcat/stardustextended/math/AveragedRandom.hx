package idv.cjcat.stardustextended.math;

import openfl.Vector;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * This class calls a <code>Random</code> object's <code>random()</code> method multiple times,
 * and averages the value.
 *
 * <p>
 * The larger the sample count, the more normally distributed the results.
 * </p>
 */
class AveragedRandom extends Random {
	public var randomObj:Random;
	public var sampleCount:Int;

	public function new(randomObj:Random = null, sampleCount:Int = 3) {
		super();
		this.randomObj = randomObj;
		this.sampleCount = sampleCount;
	}

	final override public function random():Float {
		if (randomObj == null) {
			return 0;
		}

		var sum:Float = 0;
		for (i in 0...sampleCount) {
			sum += randomObj.random();
		}

		return sum / sampleCount;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getRelatedObjects():Vector<StardustElement> {
		
		return new Vector<StardustElement>([randomObj]);
	}

	override public function getXMLTagName():String {
		return "AveragedRandom";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("randomObj", randomObj.name);
		xml.set("sampleCount", Std.string(sampleCount));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("randomObj")) {
			randomObj = try cast(builder.getElementByName(xml.get("randomObj")), Random) catch (e:Dynamic) null;
		}
		if (xml.exists("sampleCount")) {
			sampleCount = Std.parseInt(xml.get("sampleCount"));
		}
	}
}
