package idv.cjcat.stardustextended.flashdisplay.initializers;

import idv.cjcat.stardustextended.initializers.Initializer;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.flashdisplay.utils.Construct;

/**
 * Assigns a display object to the <code>target</code> properties of a particle.
 * This information can be visualized by <code>DisplayObjectRenderer</code> and <code>BitmapRenderer</code>.
 *
 * <p>
 * Default priority = 1;
 * </p>
 *
 */
class DisplayObjectClass extends Initializer {
	public var displayObjectClass:Class<Dynamic>;
	public var constructorParams:Array<Dynamic>;

	public function new(displayObjectClass:Class<Dynamic> = null, constructorParams:Array<Dynamic> = null) {
		super();
		priority = 1;

		this.displayObjectClass = displayObjectClass;
		this.constructorParams = constructorParams;
	}

	override public function initialize(p:Particle):Void {
		if (displayObjectClass == null) {
			return;
		}
		p.target = Construct.construct(displayObjectClass, constructorParams);
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "DisplayObjectClass";
	}
}
