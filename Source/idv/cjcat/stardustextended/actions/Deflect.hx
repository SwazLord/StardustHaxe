package idv.cjcat.stardustextended.actions;

import openfl.Vector;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.actions.triggers.DeflectorTrigger;
import idv.cjcat.stardustextended.deflectors.Deflector;
import idv.cjcat.stardustextended.geom.MotionData4D;

/**
 * This action is useful to manipulate a particle's position and velocity as you like.
 *
 * <p>
 * Each deflector returns a <code>MotionData4D</code> object, which contains four numeric properties: x, y, vx, and vy,
 * according to the particle's position and velocity.
 * The particle's position and velocity are then reassigned to the new values (x, y) and (vx, vy), respectively.
 * </p>
 *
 * <p>
 * Deflectors can be used to create obstacles, bounding boxes, etc.
 * </p>
 *
 * <p>
 * Default priority = -5;
 * </p>
 *
 * @see idv.cjcat.stardustextended.deflectors.Deflector
 */
class Deflect extends Action {
	private var _deflectors:Vector<Deflector>;
	private var hasTrigger:Bool;

	public function new() {
		super();
		priority = -5;
		_deflectors = new Vector<Deflector>();
	}

	/**
	 * Adds a deflector to the simulation.
	 * @param deflector
	 */
	public function addDeflector(deflector:Deflector):Void {
		if (_deflectors.indexOf(deflector) < 0)
			_deflectors.push(deflector);
	}

	/**
	 * Removes a deflector from the simulation.
	 * @param deflector
	 */
	public function removeDeflector(deflector:Deflector):Void {
		var index:Int = _deflectors.indexOf(deflector);
		if (index >= 0)
			_deflectors.splice(index, 1);
	}

	/**
	 * Removes all deflectors from the simulation.
	 */
	public function clearDeflectors():Void {
		_deflectors = new Vector<Deflector>();
	}

	public var deflectors(get, set):Vector<Deflector>;

	private function get_deflectors():Vector<Deflector> {
		return _deflectors;
	}

	private function set_deflectors(val:Vector<Deflector>):Vector<Deflector> {
		return _deflectors = val;
	}

	override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		for (deflector in _deflectors) {
			var md4D:MotionData4D = deflector.getMotionData4D(particle);
			if (md4D != null) {
				if (hasTrigger)
					particle.dictionary[deflector] = true;
				particle.x = md4D.x;
				particle.y = md4D.y;
				particle.vx = md4D.vx;
				particle.vy = md4D.vy;
			} else if (hasTrigger) {
				particle.dictionary[deflector] = false;
			}
		}
	}

	override public function preUpdate(emitter:Emitter, time:Float):Void {
		for (action in emitter.actions) {
			if (Std.isOfType(action, DeflectorTrigger)) {
				hasTrigger = true;
				return;
			}
		}
		hasTrigger = false;
	}

	// XML
	//------------------------------------------------------------------------------------------------

	override public function getRelatedObjects():Vector<StardustElement> {
		return cast _deflectors;
	}

	override public function getXMLTagName():String {
		return "Deflect";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		if (_deflectors.length > 0) {
			xml.addChild(Xml.createElement("deflectors"));
			for (deflector in _deflectors) {
				xml.elementsNamed("deflectors").next().addChild(deflector.getXMLTag());
			}
		}

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		clearDeflectors();
		for (node in xml.elementsNamed("deflectors").next().elementsNamed("node")) {
			addDeflector(cast builder.getElementByName(node.get("name")));
		}
	}

	//------------------------------------------------------------------------------------------------
	// end of XML
}
