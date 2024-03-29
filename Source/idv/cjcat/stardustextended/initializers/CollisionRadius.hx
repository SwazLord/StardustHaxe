package idv.cjcat.stardustextended.initializers;

import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Particles are simulated as circles for collision simulation.
 *
 * <p>
 * This initializer sets the collision radius of a particle.
 * </p>
 */
class CollisionRadius extends Initializer {
	/**
	 * The collsion radius.
	 */
	public var radius:Float;

	public function new(radius:Float = 0) {
		super();
		this.radius = radius;
	}

	final override public function initialize(particle:Particle):Void {
		particle.collisionRadius = radius;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "CollisionRadius";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("radius", Std.string(radius));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("radius")) {
			radius = Std.parseFloat(xml.get("radius"));
		}
	}
}
