package idv.cjcat.stardustextended.actions;

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
	public var waypoints(get, set):Array<Waypoint>;

	/**
	 * Whether the particles head for the first waypoint after passing through the last waypoint.
	 */
	public var loop:Bool;

	/**
	 * Whether the particles' mass is taken into account.
	 * If true, the acceleration applied to a particle is divided by the particle's mass.
	 */
	public var massless:Bool;

	private var _waypoints:Array<Waypoint>;
	private var _timeDeltaOneSec:Float;

	public function new(waypoints:Array<Waypoint> = null, loop:Bool = false, massless:Bool = true) {
		super();
		this.loop = loop;
		this.massless = massless;
		this.waypoints = waypoints;
		if (waypoints != null) {
			_waypoints = waypoints;
		} else {
			_waypoints = new Array<Waypoint>();
			_waypoints.push(new Waypoint(0, 0));
		}
	}

	/**
	 * An array of waypoints.
	 */
	private function get_waypoints():Array<Waypoint> {
		return _waypoints;
	}

	private function set_waypoints(value:Array<Waypoint>):Array<Waypoint> {
		if (value == null) {
			value = new Array<Waypoint>();
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
		_waypoints = new Array<Waypoint>();
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
			index = as3hx.Compat.parseInt(numWPs - 1);
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

		var waypointsXML:Xml = Xml.parse("<waypoints/>");
		for (waypoint in _waypoints) {
			var waypointXML:Xml = Xml.parse("<Waypoint/>");
			waypointXML.setAttribute("x", waypoint.x);
			waypointXML.setAttribute("y", waypoint.y);
			waypointXML.setAttribute("radius", waypoint.radius);
			waypointXML.setAttribute("strength", waypoint.strength);
			waypointXML.setAttribute("attenuationPower", waypoint.attenuationPower);
			waypointXML.setAttribute("epsilon", waypoint.epsilon);

			waypointsXML.node.appendChild.innerData(waypointXML);
		}
		xml.node.appendChild.innerData(waypointsXML);
		xml.setAttribute("loop", loop);
		xml.setAttribute("massless", massless);
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		clearWaypoints();
		for (node /* AS3HX WARNING could not determine type for var: node exp: EField(EField(EIdent(xml),waypoints),Waypoint) type: null */ in xml.nodes.waypoints.node.Waypoint.innerData) {
			var waypoint:Waypoint = new Waypoint();
			waypoint.x = as3hx.Compat.parseFloat(node.att.x);
			waypoint.y = as3hx.Compat.parseFloat(node.att.y);
			waypoint.radius = as3hx.Compat.parseFloat(node.att.radius);
			waypoint.strength = as3hx.Compat.parseFloat(node.att.strength);
			waypoint.attenuationPower = as3hx.Compat.parseFloat(node.att.attenuationPower);
			waypoint.epsilon = as3hx.Compat.parseFloat(node.att.epsilon);

			addWaypoint(waypoint);
		}
		loop = (xml.att.loop == "true");
		massless = (xml.att.massless == "true");
	}
}
