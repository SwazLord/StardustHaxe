package idv.cjcat.stardustextended.flashdisplay.bursters;

import openfl.Vector;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * Bursts out particles from a single point, spreading out at uniformly distributed angles.
 *
 * <p>
 * Adding any initializers that alters the particles' velocities essentially does nothing,
 * since this burster internally sets particles' velocities.
 * </p>
 */
class PointUniburster extends Burster {
	/**
	 * The number of particles (i.e. directions) in a single burst.
	 */
	public var count:Int;

	/**
	 * The X coordinate of the bursting origin.
	 */
	public var x:Float;

	/**
	 * The Y coordinate of the bursting origin.
	 */
	public var y:Float;

	/**
	 * The initiail speed of particles bursted out.
	 */
	public var speed:Float;

	/**
	 * Sets the angle offset of direction for a particle.
	 * The others' velocity directions will change along.
	 * Zero angle offset points upward.
	 */
	public var angleOffset:Float;

	/**
	 * Whether particles are oriented to their initial velocity directions when created, true by default.
	 */
	public var oriented:Bool;

	/**
	 * Orientation offset.
	 */
	public var orientationOffset:Float;

	public function new(count:Int = 1, x:Float = 0, y:Float = 0, speed:Float = 1, angleOffset:Float = 0, oriented:Bool = true, orientationOffset:Float = 0) {
		super();
		this.count = count;
		this.x = x;
		this.y = y;
		this.speed = speed;
		this.angleOffset = angleOffset;
		this.oriented = oriented;
		this.orientationOffset = orientationOffset;
	}

	override public function createParticles(currentTime:Float):Vector<Particle> {
		var particles:Vector<Particle> = factory.createParticles(count, currentTime);
		var len:Int = particles.length;
		var len_inv:Float = 1 / len;
		var angleOffset_rad:Float = angleOffset * StardustMath.DEGREE_TO_RADIAN;
		var p:Particle;
		var index:Int = 0;
		for (i in 0...len) {
			p = particles[index];
			p.x = x;
			p.y = y;
			p.vx = speed * Math.sin(StardustMath.TWO_PI * len_inv * i + angleOffset_rad);
			p.vy = -speed * Math.cos(StardustMath.TWO_PI * len_inv * i + angleOffset_rad);
			if (oriented) {
				p.rotation = 360 * len_inv * i + orientationOffset;
			}
			index++;
		}
		return particles;
	}
}
