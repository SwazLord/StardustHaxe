package idv.cjcat.stardustextended.initializers;

import openfl.Vector;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Sets a particle's life value based on the <code>random</code> property.
 */
class Life extends Initializer {
	public var random(get, set):Random;

	private var _random:Random;

	public function new(random:Random = null) {
		super();
		this.random = random;
	}

	inline final override public function initialize(particle:Particle):Void {
		particle.initLife = particle.life = random.random();
	}

	/**
	 * A partilce's life is set according to this property.
	 */
	private function get_random():Random {
		return _random;
	}

	private function set_random(value:Random):Random {
		if (value == null) {
			value = new UniformRandom(0, 0);
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
		return "Life";
	}

	override public function toXML():Xml {
		var xml:Xml = cast super.toXML();

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
