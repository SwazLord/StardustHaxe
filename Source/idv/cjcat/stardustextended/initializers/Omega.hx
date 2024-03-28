package idv.cjcat.stardustextended.initializers;

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.math.Random;
import idv.cjcat.stardustextended.math.UniformRandom;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Sets a particle's omega value (rotation speed), in degrees per second, based on the <code>random</code> property.
 */
class Omega extends Initializer {
	public var random(get, set):Random;

	private var _random:Random;

	public function new(random:Random = null) {
		super();
		this.random = random;
	}

	override public function initialize(particle:Particle):Void {
		particle.omega = _random.random();
	}

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

	override public function getRelatedObjects():Array<StardustElement> {
		return [_random];
	}

	override public function getXMLTagName():String {
		return "Omega";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("random", _random.name);

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("random")) {
			random = try cast(builder.getElementByName(xml.get("random")), Random) catch (e:Dynamic) null;
		}
	}
}
