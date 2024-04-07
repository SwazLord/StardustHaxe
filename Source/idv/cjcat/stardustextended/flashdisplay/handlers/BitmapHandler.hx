package idv.cjcat.stardustextended.flashdisplay.handlers;

import openfl.Vector;
import openfl.display.DisplayObject;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.handlers.ParticleHandler;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * This handler draws display object particles into a bitmap.
 */
class BitmapHandler extends ParticleHandler {
	/**
	 * The target bitmap to draw display object into.
	 */
	public var targetBitmapData:BitmapData;

	/**
	 * The blend mode for drawing.
	 */
	public var blendMode:String;

	public function new(targetBitmapData:BitmapData = null, blendMode:String = "normal") {
		super();
		this.targetBitmapData = targetBitmapData;
		this.blendMode = blendMode;
	}

	private var displayObj:DisplayObject;
	private var mat:Matrix = new Matrix();
	private var colorTransform:ColorTransform = new ColorTransform(1, 1, 1);

	override public function stepEnd(emitter:Emitter, particles:Vector<Particle>, time:Float):Void {
		for (particle in particles) {
			displayObj = cast((particle.target), DisplayObject);

			mat.identity();
			mat.scale(particle.scale, particle.scale);
			mat.rotate(particle.rotation * StardustMath.DEGREE_TO_RADIAN);
			mat.translate(particle.x, particle.y);

			colorTransform.alphaMultiplier = particle.alpha;

			targetBitmapData.draw(displayObj, mat, colorTransform, blendMode);
		}
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "BitmapHandler";
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
