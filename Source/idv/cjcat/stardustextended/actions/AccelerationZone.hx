package idv.cjcat.stardustextended.actions;

import openfl.Vector;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;
import idv.cjcat.stardustextended.zones.RectZone;
import idv.cjcat.stardustextended.zones.Zone;
import idv.cjcat.stardustextended.zones.ZoneCollection;

/**
 * Causes particles to change acceleration specified zone.
 *
 * <p>
 * Default priority = -6;
 * </p>
 */
class AccelerationZone extends Action implements IZoneContainer {
	public var direction(get, set):Vec2D;
	public var zones(get, set):Vector<Zone>;

	/**
	 * Inverts the zone region.
	 */
	public var inverted:Bool;

	/**
	 * The acceleration applied in each step to particles inside the zone.
	 */
	public var acceleration:Float;

	/**
	 * Flag whether to use the particle's speed or the direction variable. Default is true.
	 */
	public var useParticleDirection:Bool;

	private var _direction:Vec2D;

	/**
	 * the direction of the acceleration. Only used if useParticleDirection is true
	 */
	private function get_direction():Vec2D {
		return _direction;
	}

	private function set_direction(value:Vec2D):Vec2D {
		value.length = 1;
		_direction = value;
		return value;
	}

	private var zoneCollection:ZoneCollection;

	private function get_zones():Vector<Zone> {
		return zoneCollection.zones;
	}

	private function set_zones(value:Vector<Zone>):Vector<Zone> {
		zoneCollection.zones = value;
		return value;
	}

	public function new(zones:Vector<Zone> = null, _inverted:Bool = false) {
		super();
		priority = -6;

		inverted = _inverted;
		acceleration = 200;
		useParticleDirection = true;
		_direction = Vec2DPool.get(100, 0);
		zoneCollection = new ZoneCollection();
		if (zones != null) {
			zoneCollection.zones = zones;
		} else {
			zoneCollection.zones.push(new RectZone());
		}
	}

	override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		var affected:Bool = zoneCollection.contains(particle.x, particle.y);
		if (inverted) {
			affected = !affected;
		}
		if (affected) {
			if (useParticleDirection) {
				var v:Vec2D = Vec2DPool.get(particle.vx, particle.vy);
				var vecLength:Float = v.length;
				if (vecLength > 0) {
					var finalVal:Float = vecLength + acceleration * timeDelta;
					if (finalVal < 0) {
						finalVal = 0;
					}
					v.length = finalVal;
					particle.vx = v.x;
					particle.vy = v.y;
				}
				Vec2DPool.recycle(v);
			} else {
				var finalX:Float = particle.vx + acceleration * _direction.x * timeDelta;
				var finalY:Float = particle.vy + acceleration * _direction.y * timeDelta;
				particle.vx = finalX;
				particle.vy = finalY;
			}
		}
	}

	// Xml
	//------------------------------------------------------------------------------------------------
	override public function getRelatedObjects():Vector<StardustElement> {
		return cast zoneCollection.zones;
	}

	override public function getXMLTagName():String {
		return "AccelerationZone";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();
		zoneCollection.addToStardustXML(xml);
		xml.set("inverted", Std.string(inverted));
		xml.set("acceleration", Std.string(acceleration));
		xml.set("useParticleDirection", Std.string(useParticleDirection));
		xml.set("directionX", Std.string(_direction.x));
		xml.set("directionY", Std.string(_direction.y));
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);
		if (xml.exists("zone")) {
			trace("WARNING: the simulation contains a deprecated property 'zone' for " + getXMLTagName());
			zoneCollection.zones = cast builder.getElementByName(xml.get("zone"));
		} else {
			zoneCollection.parseFromStardustXML(xml, builder);
		}
		inverted = (xml.get("inverted") == "true");
		acceleration = Std.parseFloat(xml.get("acceleration"));
		useParticleDirection = (xml.get("useParticleDirection") == "true");
		_direction.x = Std.parseFloat(xml.get("directionX"));
		_direction.y = Std.parseFloat(xml.get("directionY"));
	}
}
