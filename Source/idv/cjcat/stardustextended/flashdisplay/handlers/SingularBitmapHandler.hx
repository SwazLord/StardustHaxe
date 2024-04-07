package idv.cjcat.stardustextended.flashdisplay.handlers;

import openfl.Vector;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.handlers.ParticleHandler;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Similar to the <code>BitmapHandler</code>, but uses only one display object for drawing the target bitmap.
 *
 * @see idv.cjcat.stardustextended.flashdisplay.handlers.BitmapHandler
 */
class SingularBitmapHandler extends ParticleHandler {
	public var displayObject:DisplayObject;
	public var targetBitmapData:BitmapData;
	public var blendMode:String;

	public function new(displayObject:DisplayObject = null, targetBitmapData:BitmapData = null, blendMode:String = "normal") {
		super();
		this.displayObject = displayObject;
		this.targetBitmapData = targetBitmapData;
		this.blendMode = blendMode;
	}

	private var mat:Matrix = new Matrix();
	private var colorTransform:ColorTransform = new ColorTransform(1, 1, 1);

	override public function stepEnd(emitter:Emitter, particles:Vector<Particle>, time:Float):Void {
		for (particle in particles) {
			mat.identity();
			mat.scale(particle.scale, particle.scale);
			mat.rotate(particle.rotation * StardustMath.DEGREE_TO_RADIAN);
			mat.translate(particle.x, particle.y);

			colorTransform.alphaMultiplier = particle.alpha;

			targetBitmapData.draw(displayObject, mat, colorTransform, blendMode);
		}
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "SingularBitmapHandler";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("blendMode", blendMode);

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("blendMode")) {
			blendMode = xml.get("blendMode");
		}
	}
}
