package idv.cjcat.stardustextended.initializers;

import openfl.Vector;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Sets a particle's alpha value based on the <code>random</code> property.
 */
class Alpha extends Initializer {
	public var random(get, set):Random;

	private var _random:Random;

	public function new(random:Random = null) {
		super();
		this.random = random;
	}

	final override public function initialize(particle:Particle):Void {
		particle.initAlpha = particle.alpha = random.random();
	}

	private function get_random():Random {
		return _random;
	}

	private function set_random(value:Random):Random {
		if (value == null) {
			value = new UniformRandom(1, 0);
		}
		_random = value;
		return value;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getRelatedObjects():Vector<StardustElement> {
		return new Vector<StardustElement>([_random]);
	}

	override public function getXMLTagName():String {
		return "Alpha";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("random", Std.string(_random.name));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("random")) {
			random = try cast(builder.getElementByName(xml.get("random")), Random) catch (e:Dynamic) null;
		}
	}
}
