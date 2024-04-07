package idv.cjcat.stardustextended.actions;

import openfl.Vector;
import idv.cjcat.stardustextended.actions.waypoints.Waypoint;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.Vec2D;
import idv.cjcat.stardustextended.geom.Vec2DPool;

/**
 * Causes particles to go through a series of waypoints.
 *
 * @see idv.cjcat.stardustextended.actions.waypoints.Waypoint
 */
class FollowWaypoints extends Action {
	public var waypoints(get, set):Vector<Waypoint>;

	/**
	 * Whether the particles head for the first waypoint after passing through the last waypoint.
	 */
	public var loop:Bool;

	/**
	 * Whether the particles' mass is taken into account.
	 * If true, the acceleration applied to a particle is divided by the particle's mass.
	 */
	public var massless:Bool;

	private var _waypoints:Vector<Waypoint>;
	private var _timeDeltaOneSec:Float;

	public function new(waypoints:Vector<Waypoint> = null, loop:Bool = false, massless:Bool = true) {
		super();
		this.loop = loop;
		this.massless = massless;
		this.waypoints = waypoints;
		if (waypoints != null) {
			_waypoints = waypoints;
		} else {
			_waypoints = new Vector<Waypoint>();
			_waypoints.push(new Waypoint(0, 0));
		}
	}

	/**
	 * An array of waypoints.
	 */
	private function get_waypoints():Vector<Waypoint> {
		return _waypoints;
	}

	private function set_waypoints(value:Vector<Waypoint>):Vector<Waypoint> {
		if (value == null) {
			value = new Vector<Waypoint>();
		}
		_waypoints = value;
		return value;
	}

	/**
	 * Adds a waypoint to the waypoint array.
	 * @param    waypoint
	 */
	public function addWaypoint(waypoint:Waypoint):Void {
		_waypoints.push(waypoint);
	}

	/**
	 * Removes all waypoints from the waypoint array.
	 */
	public function clearWaypoints():Void {
		_waypoints = new Vector<Waypoint>();
	}

	override public function preUpdate(emitter:Emitter, time:Float):Void {
		_timeDeltaOneSec = time * 60;
	}

	override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		var numWPs:Int = _waypoints.length;
		if (numWPs == 0) {
			return;
		}

		if (particle.dictionary[FollowWaypoints] == null) {
			particle.dictionary[FollowWaypoints] = 0;
		}

		var index:Int = particle.dictionary[FollowWaypoints];
		if (index >= numWPs) {
			index = Std.int(numWPs - 1);
			particle.dictionary[FollowWaypoints] = index;
		}

		var waypoint:Waypoint = try cast(_waypoints[index], Waypoint) catch (e:Dynamic) null;
		var dx:Float = particle.x - waypoint.x;
		var dy:Float = particle.y - waypoint.y;
		if (dx * dx + dy * dy <= waypoint.radius * waypoint.radius) {
			if (index < numWPs - 1) {
				particle.dictionary[FollowWaypoints]++;
				waypoint = _waypoints[index + 1];
			} else if (loop) {
				particle.dictionary[FollowWaypoints] = 0;
				waypoint = _waypoints[0];
			} else {
				return;
			}
			dx = particle.x - waypoint.x;
			dy = particle.y - waypoint.y;
		}

		var r:Vec2D = Vec2DPool.get(dx, dy);
		var len:Float = r.length;
		if (len < waypoint.epsilon) {
			len = waypoint.epsilon;
		}
		r.length = -waypoint.strength * Math.pow(len, -0.5 * waypoint.attenuationPower);
		if (!massless) {
			r.length /= particle.mass;
		}
		Vec2DPool.recycle(r);

		particle.vx += r.x * _timeDeltaOneSec;
		particle.vy += r.y * _timeDeltaOneSec;
	}

	// Xml
	//------------------------------------------------------------------------------------------------
	override public function getXMLTagName():String {
		return "FollowWaypoints";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		var waypointsXML:Xml = Xml.createElement("waypoints");
		for (waypoint in _waypoints) {
			var waypointXML:Xml = Xml.createElement("Waypoint");
			waypointXML.set("x", Std.string(waypoint.x));
			waypointXML.set("y", Std.string(waypoint.y));
			waypointXML.set("radius", Std.string(waypoint.radius));
			waypointXML.set("strength", Std.string(waypoint.strength));
			waypointXML.set("attenuationPower", Std.string(waypoint.attenuationPower));
			waypointXML.set("epsilon", Std.string(waypoint.epsilon));

			waypointsXML.addChild(waypointXML);
		}
		xml.addChild(waypointsXML);
		xml.set("loop", Std.string(loop));
		xml.set("massless", Std.string(massless));
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		clearWaypoints();
		for (node in xml.elementsNamed("Waypoint")) {
			var waypoint:Waypoint = new Waypoint();
			waypoint.x = Std.parseFloat(node.get("x"));
			waypoint.y = Std.parseFloat(node.get("y"));
			waypoint.radius = Std.parseFloat(node.get("radius"));
			waypoint.strength = Std.parseFloat(node.get("strength"));
			waypoint.attenuationPower = Std.parseFloat(node.get("attenuationPower"));
			waypoint.epsilon = Std.parseFloat(node.get("epsilon"));

			addWaypoint(waypoint);
		}
		loop = (xml.get("loop") == "true");
		massless = (xml.get("massless") == "true");
	}
}
