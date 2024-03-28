package idv.cjcat.stardustextended.fields;

import openfl.geom.Point;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;

/**
 * Uniform vector field. It yields a <code>MotionData2D</code> object of same X and Y components no matter what.
 *
 * <p>
 * This can be used to simulate uniform gravity.
 * </p>
 */
class UniformField extends Field {
	/**
	 * The X component of the returned <code>MotionData2D</code> object.
	 */
	public var x:Float;

	/**
	 * The Y component of the returned <code>MotionData2D</code> object.
	 */
	public var y:Float;

	public function new(x:Float = 0, y:Float = 0) {
		super();
		this.x = x;
		this.y = y;
	}

	override private function calculateMotionData2D(particle:Particle):MotionData2D {
		return MotionData2DPool.get(x, y);
	}

	override public function setPosition(xc:Float, yc:Float):Void { // do nothing, position can not be set on this field.
	}

	override public function getPosition():Point {
		position.setTo(0, 0);
		return position;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "UniformField";
	}

	override public function toXML():Xml {
		var xml:Xml = cast super.toXML();

		xml.set("x", Std.string("x"));
		xml.set("y", Std.string("y"));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("x")) {
			x = Std.parseFloat(xml.get("x"));
		}
		if (xml.exists("y")) {
			y = Std.parseFloat(xml.get("y"));
		}
	}
}
