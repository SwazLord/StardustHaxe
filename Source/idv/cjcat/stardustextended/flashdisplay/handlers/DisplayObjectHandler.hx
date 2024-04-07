package idv.cjcat.stardustextended.flashdisplay.handlers;

import openfl.Vector;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.handlers.ParticleHandler;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * This handler adds display object particles to the target container's display list,
 * removes dead particles from the display list,
 * and updates the display object's x, y, rotation, scaleX, scaleY, and alpha properties.
 */
class DisplayObjectHandler extends ParticleHandler {
	public var blendMode(get, set):String;

	public var addChildMode:Int;

	/**
	 * The target container.
	 */
	public var container:DisplayObjectContainer;

	/**
	 * Whether to change a display object's parent to the target container if the object already belongs to another parent.
	 */
	public var forceParentChange:Bool;

	/**
	 * The blend mode for drawing.
	 */
	private var _blendMode:String;

	private var displayObj:DisplayObject;

	public function new(container:DisplayObjectContainer = null, blendMode:String = "normal", addChildMode:Int = 0) {
		super();
		this.container = container;
		this.addChildMode = addChildMode;
		this.blendMode = blendMode;
		forceParentChange = false;
	}

	override public function particleAdded(particle:Particle):Void {
		displayObj = cast((particle.target), DisplayObject);
		displayObj.blendMode = _blendMode;

		if (!forceParentChange && displayObj.parent != null) {
			return;
		}

		switch (addChildMode) {
			case AddChildMode.RANDOM:
				container.addChildAt(displayObj, Math.floor(Math.random() * container.numChildren));
			case AddChildMode.TOP:
				container.addChild(displayObj);
			case AddChildMode.BOTTOM:
				container.addChildAt(displayObj, 0);
			default:
				container.addChildAt(displayObj, Math.floor(Math.random() * container.numChildren));
		}
	}

	override public function particleRemoved(particle:Particle):Void {
		displayObj = cast((particle.target), DisplayObject);
		displayObj.parent.removeChild(displayObj);
	}

	override public function stepEnd(emitter:Emitter, particles:Vector<Particle>, time:Float):Void {
		for (particle in particles) {
			displayObj = cast((particle.target), DisplayObject);

			displayObj.x = particle.x;
			displayObj.y = particle.y;
			displayObj.rotation = particle.rotation;
			displayObj.scaleX = displayObj.scaleY = particle.scale;
			displayObj.alpha = particle.alpha;
		}
	}

	private function set_blendMode(val:String):String {
		_blendMode = val;
		return val;
	}

	private function get_blendMode():String {
		return _blendMode;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "DisplayObjectHandler";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("addChildMode", Std.string(addChildMode));
		xml.set("forceParentChange", Std.string(forceParentChange));
		xml.set("blendMode", _blendMode);

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("addChildMode")) {
			addChildMode = Std.int(Std.parseFloat(xml.get("addChildMode")));
		}
		if (xml.exists("forceParentChange")) {
			forceParentChange = (xml.get("forceParentChange") == "true");
		}
		if (xml.exists("blendMode")) {
			blendMode = (xml.get("blendMode"));
		}
	}
}
