package idv.cjcat.stardustextended.actions;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Causes particles' rotation to align to their velocities.
 *
 * <p>
 * Default priority = -6;
 * </p>
 */
class Oriented extends Action {
	/**
	 * How fast the particles align to their velocities, 0 means no alignment at all.
	 */
	public var factor:Float;

	/**
	 * The rotation angle offset in degrees.
	 */
	public var offset:Float;

	private var _timeDeltaOneSec:Float;

	public function new(factor:Float = 1, offset:Float = 0) {
		super();
		priority = -6;

		this.factor = factor;
		this.offset = offset;
	}

	private var f:Float;
	private var os:Float;

	override public function preUpdate(emitter:Emitter, time:Float):Void {
		f = Math.pow(factor, 0.1 / time);
		os = offset + 90;
		_timeDeltaOneSec = (time + Emitter.timeStepCorrectionOffset) * 60;
		if (_timeDeltaOneSec > 1) {
			_timeDeltaOneSec = 1;
		}
	}

	override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		var displacement:Float = (Math.atan2(particle.vy, particle.vx) * StardustMath.RADIAN_TO_DEGREE + os) - particle.rotation;
		particle.rotation += f * displacement * _timeDeltaOneSec;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "Oriented";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.setAttribute("factor", factor);
		xml.setAttribute("offset", offset);

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.att.factor.length()) {
			factor = as3hx.Compat.parseFloat(xml.att.factor);
		}
		if (xml.att.offset.length()) {
			offset = as3hx.Compat.parseFloat(xml.att.offset);
		}
	}
}
