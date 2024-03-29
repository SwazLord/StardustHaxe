package idv.cjcat.stardustextended.actions;

import openfl.Vector;
import haxe.io.Bytes;
import openfl.display.BitmapData;
import openfl.display.GradientType;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.utils.ColorUtil;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Alters a particle's color during its lifetime based on a gradient.
 */
class ColorGradient extends Action {
	/**
	 * Number of gradient steps. Higher values result in smoother transition, but more memory usage.
	 */
	public var numSteps:Int = 500;

	var _colors:Array<Int>;
	var _ratios:Array<Int>;
	var _alphas:Array<Float>;
	var colorRs:Vector<Float>;
	var colorBs:Vector<Float>;
	var colorGs:Vector<Float>;
	var colorAlphas:Vector<Float>;

	public var colors(get, never):Array<Int>;

	inline function get_colors():Array<Int> {
		return _colors;
	}

	public var ratios(get, never):Array<Int>;

	inline function get_ratios():Array<Int> {
		return _ratios;
	}

	public var alphas(get, never):Array<Float>;

	inline function get_alphas():Array<Float> {
		return _alphas;
	}

	/**
	 *
	 * @param setDefaultValues Set some default values to start with. Leave it false if you set value manually to
	 *        prevent parsing twice
	 */
	public function new(setDefaultValues:Bool = false) {
		super();
		if (setDefaultValues) {
			setGradient([0x00FF00, 0xFF0000], [0, 255], [1, 1]);
		}
	}

	/**
	 * Sets the gradient values. Both vectors must be the same length, and must have less than 16 values.
	 * @param colors Array of uint colors HEX RGB colors
	 * @param ratios Array of uint ratios ordered, in increasing order. First value should be 0, last 255.
	 * @param alphas Array of Number alphas in the 0-1 range.
	 */
	public final function setGradient(colors:Array<Int>, ratios:Array<Int>, alphas:Array<Float>):Void {
		_colors = colors;
		_ratios = ratios;
		_alphas = alphas;
		colorRs = new Vector<Float>();
		colorBs = new Vector<Float>();
		colorGs = new Vector<Float>();
		colorAlphas = new Vector<Float>();

		var mat:Matrix = new Matrix();
		mat.createGradientBox(numSteps, 1);
		var sprite:Sprite = new Sprite();
		sprite.graphics.lineStyle();
		sprite.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, mat);
		sprite.graphics.drawRect(0, 0, numSteps, 1);
		sprite.graphics.endFill();
		var bd:BitmapData = new BitmapData(numSteps, 1, true, 0x00000000);
		bd.draw(sprite);
		for (i in 0...numSteps) {
			var color:Int = bd.getPixel32(numSteps - 1 - i, 0);
			colorRs.push(ColorUtil.extractRed(color));
			colorBs.push(ColorUtil.extractBlue(color));
			colorGs.push(ColorUtil.extractGreen(color));
			colorAlphas.push(ColorUtil.extractAlpha32(color));
		}
		colorRs.fixed = true;
		colorBs.fixed = true;
		colorGs.fixed = true;
		colorAlphas.fixed = true;
		bd.dispose();
	}

	override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		var ratio:Int = Std.int((numSteps - 1) * particle.life / particle.initLife);

		particle.colorR = colorRs[ratio];
		particle.colorB = colorBs[ratio];
		particle.colorG = colorGs[ratio];
		particle.alpha = colorAlphas[ratio];
	}

	// XML
	//------------------------------------------------------------------------------------------------
	override public function getXMLTagName():String {
		return "ColorGradient";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		var colorsStr:String = "";
		var ratiosStr:String = "";
		var alphasStr:String = "";
		for (i in 0..._colors.length) {
			colorsStr += _colors[i] + ",";
			ratiosStr += _ratios[i] + ",";
			alphasStr += _alphas[i] + ",";
		}
		xml.set("colors", colorsStr.substr(0, colorsStr.length - 1));
		xml.set("ratios", ratiosStr.substr(0, ratiosStr.length - 1));
		xml.set("alphas", alphasStr.substr(0, alphasStr.length - 1));

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		setGradient(xml.get("colors").split(",").map(function(s) return Std.parseInt(s)),
			xml.get("ratios").split(",").map(function(s) return Std.parseInt(s)), xml.get("alphas").split(",").map(function(s) return Std.parseFloat(s)));
	}

	//------------------------------------------------------------------------------------------------
	// end of XML
}
