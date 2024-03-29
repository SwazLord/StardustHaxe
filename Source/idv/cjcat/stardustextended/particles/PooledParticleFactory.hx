package idv.cjcat.stardustextended.particles;

import openfl.Vector;
import idv.cjcat.stardustextended.initializers.Initializer;
import idv.cjcat.stardustextended.initializers.InitializerCollection;

class PooledParticleFactory {
	public var initializerCollection(get, never):InitializerCollection;

	private var _initializerCollection:InitializerCollection;

	public function new() {
		_initializerCollection = new InitializerCollection();
	}

	/**
	 * Creates particles with associated initializers.
	 * @param count
	 * @param currentTime
	 * @param toVector The vector the particles will be added to to prevent object allocation
	 * @return the newly created particles
	 */
	inline final public function createParticles(count:Int, currentTime:Float, toVector:Vector<Particle> = null):Vector<Particle> {
		var particles:Vector<Particle> = toVector;

		if (particles == null) {
			particles = new Vector<Particle>();
		}

		if (count > 0) {
			var i:Int;

			for (i in 0...count) {
				var particle:Particle = ParticlePool.get();

				particle.init();
				particles.push(particle);
			}

			var initializers:Vector<Initializer> = _initializerCollection.initializers;
			var len:Int = initializers.length;

			for (i in 0...len) {
				initializers[i].doInitialize(particles, currentTime);
			}
		}

		return particles;
	}

	/**
	 * Adds an initializer to the factory.
	 * @param    initializer
	 */
	public function addInitializer(initializer:Initializer):Void {
		_initializerCollection.addInitializer(initializer);
	}

	/**
	 * Removes an initializer from the factory.
	 * @param    initializer
	 */
	final public function removeInitializer(initializer:Initializer):Void {
		_initializerCollection.removeInitializer(initializer);
	}

	/**
	 * Removes all initializers from the factory.
	 */
	final public function clearInitializers():Void {
		_initializerCollection.clearInitializers();
	}

	private function get_initializerCollection():InitializerCollection {
		return _initializerCollection;
	}

	inline final public function recycle(particle:Particle):Void {
		ParticlePool.recycle(particle);
	}
}
