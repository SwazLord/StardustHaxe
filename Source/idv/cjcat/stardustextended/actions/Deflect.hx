package idv.cjcat.stardustextended.actions;

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
	private var _deflectors:Array<Deflector>;
	private var hasTrigger:Bool;

	public function new() {
		priority = -5;
		_deflectors = new Array<Deflector>();
	}

	/**
	 * Adds a deflector to the simulation.
	 * @param    deflector
	 */
	public function addDeflector(deflector:Deflector):Void {
		if (_deflectors.indexOf(deflector) < 0)
			_deflectors.push(deflector);
	}

	/**
	 * Removes a deflector from the simulation.
	 * @param    deflector
	 */
	public function removeDeflector(deflector:Deflector):Void {
		var index:Int = _deflectors.indexOf(deflector);
		if (_deflectors.indexOf(deflector) >= 0)
			_deflectors.removeAt(index);
	}

	/**
	 * Removes all deflectors from the simulation.
	 */
	public function clearDeflectors():Void {
		_deflectors = new Array<Deflector>();
	}

	public var deflectors(get, set):Array<Deflector>;

	public function get_deflectors():Array<Deflector> {
		return _deflectors;
	}

	public function set_deflectors(val:Array<Deflector>):Void {
		_deflectors = val;
	}

	override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		for (deflector in _deflectors) {
			var md4D:MotionData4D = deflector.getMotionData4D(particle);
			if (md4D) {
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
			if (action is DeflectorTrigger) {
				hasTrigger = true;
				return;
			}
		}
		hasTrigger = false;
	}

	// XML
	//------------------------------------------------------------------------------------------------

	override public function getRelatedObjects():Array<StardustElement> {
		return Array<StardustElement>(_deflectors);
	}

	override public function getXMLTagName():String {
		return "Deflect";
	}

	override public function toXML():XML {
		var xml:XML = super.toXML();

		if (_deflectors.length > 0) {
			xml.appendChild(<deflectors/>);
			var deflector:Deflector;
			for (deflector in _deflectors) {
				xml.deflectors.appendChild(deflector.getXMLTag());
			}
		}

		return xml;
	}

	override public function parseXML(xml:XML, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);
		var access = new haxe.xml.Access(xml);
		clearDeflectors();
		for (node in access.node.deflectors.elements) {
			addDeflector(cast(builder.getElementByName(node.att.name), Deflector));
		}
	}

	//------------------------------------------------------------------------------------------------
	// end of XML
}
