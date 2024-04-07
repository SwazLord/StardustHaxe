package idv.cjcat.stardustextended.actions;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * TODO: get it working
 * [Abstract Class] This is an abstract class for mutual actions such as collision and mutual gravity.
 */
class MutualAction extends Action {
	/**
	 * Only when the distance between two particles is less than this value will these particles be processed.
	 */
	public var maxDistance:Float;

	public function new() {
		super();
	}

	override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		/*
			var p1:Particle2D = Particle2D(particle);
			var p2:Particle2D;
			var yDist:Number;
			var i:ParticleIterator = particle.sortedIndexIterator;
			j = i.clone();
			while (p1 = Particle2D(i.particle())) {
			p1.sortedIndexIterator.dump(j);
			j.next();
			while (p2 = Particle2D(j.particle())) {
			yDist = p2.y - p1.y;
			if (yDist < 0) yDist = -yDist;
			if ( (p2.x - p1.x) <= maxDistance ) {
			if ( (p1.mask & p2.mask) && yDist <= maxDistance) doMutualAction(p1, p2, timeDelta);
			} else {
			break;
			}
			j.next();
			}
			i.next();
		}*/
	}

	private function doMutualAction(p1:Particle, p2:Particle, time:Float):Void {}

	/**
	 * Tells the emitter that this action needs sorted particles.
	 */
	final override public function get_needsSortedParticles():Bool {
		return active;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "MutualAction";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("maxDistance", Std.string(maxDistance));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("maxDistance")) {
			maxDistance = Std.parseFloat(xml.get("maxDistance"));
		}
	}
}
