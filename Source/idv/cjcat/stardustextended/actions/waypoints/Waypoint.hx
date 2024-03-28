package idv.cjcat.stardustextended.actions.waypoints;

import openfl.geom.Point;
import idv.cjcat.stardustextended.interfaces.IPosition;

/**
 * Waypoint used by the <code>FollowWaypoints</code> action.
 *
 * @see idv.cjcat.stardustextended.actions.FollowWaypoints
 */
class Waypoint implements IPosition {
	/**
	 * The X coordinate of the center of the waypoint.
	 */
	public var x:Float;

	/**
	 * The Y coordinate of the center of the waypoint.
	 */
	public var y:Float;

	/**
	 * The radius of the waypoint.
	 */
	public var radius:Float;

	/**
	 * The strength of the waypoint. This value must be positive.
	 */
	public var strength:Float;

	/**
	 * The attenuation power of the waypoint, in powers per pixel.
	 */
	public var attenuationPower:Float;

	/**
	 * If a point is closer to the center than this value,
	 * it's treated as if it's this far from the center.
	 * This is to prevent simulation from blowing up for points too near to the center.
	 */
	public var epsilon:Float;

	private var position:Point;

	public function new(x:Float = 0, y:Float = 0, radius:Float = 20, strength:Float = 1, attenuationPower:Float = 0, epsilon:Float = 1) {
		this.x = x;
		this.y = y;
		this.radius = radius;
		this.strength = strength;
		this.attenuationPower = attenuationPower;
		this.epsilon = epsilon;
		position = new Point(x, y);
	}

	public function setPosition(xc:Float, yc:Float):Void {
		x = xc;
		y = yc;
	}

	public function getPosition():Point {
		position.setTo(x, y);
		return position;
	}
}
