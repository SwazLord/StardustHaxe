package idv.cjcat.stardustextended.particles;

import openfl.Vector;

/**
 * This is an object pool for particle objects.
 *
 * <p>
 * Be sure to recycle a particle after getting it from the pool.
 * </p>
 */
class ParticlePool {
	private static var _recycled:Vector<Particle> = new Vector<Particle>();

	inline public static function get():Particle {
		if (_recycled.length > 0) {
			return _recycled.pop();
		} else {
			return new Particle();
		}
	}

	inline public static function recycle(particle:Particle):Void {
		_recycled.push(particle);
	}

	public function new() {}
}
