package idv.cjcat.stardustextended.actions;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Accelerates particles along their velocity directions.
 */
class Accelerate extends Action {
	/**
	 * The amount of acceleration in each second.
	 */
	public var acceleration:Float;

	private var _timeDeltaOneSec:Float;

	public function new(acceleration:Float = 60) {
		super();
		this.acceleration = acceleration;
	}

	override public function preUpdate(emitter:Emitter, time:Float):Void {
		_timeDeltaOneSec = time * 60;
	}

	private var _finalLength:Float;
	private var _updateVec:Vec2D = new Vec2D(0, 0);

	inline final override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		_updateVec.x = particle.vx;
		_updateVec.y = particle.vy;

		if (_updateVec.length > 0) {
			_finalLength = _updateVec.length + acceleration * _timeDeltaOneSec;

			if (_finalLength < 0) {
				_finalLength = 0;
			}

			_updateVec.length = _finalLength;

			particle.vx = _updateVec.x;
			particle.vy = _updateVec.y;
		}
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "Accelerate";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("acceleration", Std.string(acceleration));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("acceleration")) {
			acceleration = Std.parseFloat(xml.get("acceleration"));
		}
	}
}
