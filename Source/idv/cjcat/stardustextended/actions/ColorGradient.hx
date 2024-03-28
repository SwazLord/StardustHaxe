package idv.cjcat.stardustextended.actions;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.utils.ColorUtil;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Alters a particle's color during its lifetime based on a gradient.
 */
class ColorGradient extends Action {
	public var colors(get, never):Array<Dynamic>;
	public var ratios(get, never):Array<Dynamic>;
	public var alphas(get, never):Array<Dynamic>;

	/**
	 * Number of gradient steps. Higher values result in smoother transition, but more memory usage.
	 */
	public var numSteps:Int = 500;

	private var _colors:Array<Dynamic>;
	private var _ratios:Array<Dynamic>;
	private var _alphas:Array<Dynamic>;
	private var colorRs:Array<Float>;
	private var colorBs:Array<Float>;
	private var colorGs:Array<Float>;
	private var colorAlphas:Array<Float>;

	private function get_colors():Array<Dynamic> {
		return _colors;
	}

	private function get_ratios():Array<Dynamic> {
		return _ratios;
	}

	private function get_alphas():Array<Dynamic> {
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
	final public function setGradient(colors:Array<Dynamic>, ratios:Array<Dynamic>, alphas:Array<Dynamic>):Void {
		_colors = colors;
		_ratios = ratios;
		_alphas = alphas;
		colorRs = new Array<Float>();
		colorBs = new Array<Float>();
		colorGs = new Array<Float>();
		colorAlphas = new Array<Float>();

		var mat:Matrix = new Matrix();
		mat.createGradientBox(numSteps, 1);
		var sprite:Sprite = new Sprite();
		sprite.graphics.lineStyle();
		sprite.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, mat);
		sprite.graphics.drawRect(0, 0, numSteps, 1);
		sprite.graphics.endFill();
		var bd:BitmapData = new BitmapData(numSteps, 1, true, 0x00000000);
		bd.draw(sprite);
		var i:Int = as3hx.Compat.parseInt(numSteps - 1);
		while (i > -1) {
			var color:Int = bd.getPixel32(i, 0);
			colorRs.push(ColorUtil.extractRed(color));
			colorBs.push(ColorUtil.extractBlue(color));
			colorGs.push(ColorUtil.extractGreen(color));
			colorAlphas.push(ColorUtil.extractAlpha32(color));
			i--;
		}
		colorRs.fixed = true;
		colorBs.fixed = true;
		colorGs.fixed = true;
		colorAlphas.fixed = true;
		bd.dispose();
	}

	inline final override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		var ratio:Int = as3hx.Compat.parseInt((numSteps - 1) * particle.life / particle.initLife);

		particle.colorR = colorRs[ratio];
		particle.colorB = colorBs[ratio];
		particle.colorG = colorGs[ratio];
		particle.alpha = colorAlphas[ratio];
	}

	// Xml
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
			colorsStr = colorsStr + _colors[i] + ",";
			ratiosStr = ratiosStr + _ratios[i] + ",";
			alphasStr = alphasStr + _alphas[i] + ",";
		}
		xml.setAttribute("colors", colorsStr.substr(0, colorsStr.length - 1)) = colorsStr.substr(0, colorsStr.length - 1);
		xml.setAttribute("ratios", ratiosStr.substr(0, ratiosStr.length - 1)) = ratiosStr.substr(0, ratiosStr.length - 1);
		xml.setAttribute("alphas", alphasStr.substr(0, alphasStr.length - 1)) = alphasStr.substr(0, alphasStr.length - 1);

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		setGradient((xml.att.colors).split(","), (xml.att.ratios).split(","), (xml.att.alphas).split(","));
	}
}
