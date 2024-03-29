package idv.cjcat.stardustextended.particles;

/**
 * This class represents a particle and its properties.
 */
class Particle {
	/**
	 * The initial life upon birth.
	 */
	public var initLife:Float;

	/**
	 * The normal scale upon birth.
	 */
	public var initScale:Float;

	/**
	 * The normal alpha value upon birth.
	 */
	// [Deprecated(message="initAlpha property will be soon removed, use ColorGradient")]
	public var initAlpha:Float;

	/**
	 * The remaining life of the particle.
	 */
	public var life:Float;

	/**
	 * The scale of the particle.
	 */
	public var scale:Float;

	/**
	 * The alpha value of the particle.
	 */
	public var alpha:Float;

	/**
	 * The mass of the particle.
	 */
	public var mass:Float;

	/**
	 * Whether the particle is marked as dead.
	 *
	 * <p>
	 * Dead particles would be removed from simulation by an emitter.
	 * </p>
	 */
	public var isDead:Bool;

	/**
	 * The collision radius of the particle.
	 */
	public var collisionRadius:Float;

	/**
	 * Custom user data of the particle.
	 *
	 * <p>
	 * Normally, this property contains information for renderers.
	 * For instance this property should refer to a display object for a <code>DisplayObjectRenderer</code>.
	 * </p>
	 */
	public var target:Dynamic;

	/**
	 * current Red color component; in the [0,1] range.
	 */
	public var colorR:Float;

	/**
	 * current Green color component; in the [0,1] range.
	 */
	public var colorG:Float;

	/**
	 * current Blue color component; in the [0,1] range.
	 */
	public var colorB:Float;

	/**
	 * Dictionary for storing additional information.
	 */
	public var dictionary:Map<Dynamic, Dynamic>;

	/**
	 * Particle handlers use this property to determine which frame to display if the particle is animated
	 */
	public var currentAnimationFrame:Int = 0;

	public var x:Float;
	public var y:Float;
	public var vx:Float;
	public var vy:Float;
	public var rotation:Float;
	public var omega:Float;

	public function new() {
		dictionary = new Map<Dynamic, Dynamic>();
	}

	/**
	 * Initializes properties to default values.
	 */
	inline final public function init():Void {
		initLife = life = currentAnimationFrame = 0;
		initScale = scale = 1;
		initAlpha = alpha = 1;
		mass = 1;
		isDead = false;
		collisionRadius = 0;

		colorR = 1;
		colorB = 1;
		colorG = 1;

		x = 0;
		y = 0;
		vx = 0;
		vy = 0;
		rotation = 0;
		omega = 0;
	}

	public function destroy():Void {
		target = null;
		/* var key : Dynamic;

			for (key in Reflect.fields(dictionary))
			{
				Reflect.setField(dictionary, Std.string(key), null);
				delete dictionary[key];
		}*/

		for (key in dictionary.keys()) {
			dictionary[key] = null;
			dictionary.remove(key);
		}
	}

	inline public static function compareFunction(p1:Particle, p2:Particle):Int {
		if (p1.x < p2.x) {
			return -1;
		}

		return 1;
	}
}
