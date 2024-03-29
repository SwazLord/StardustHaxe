package idv.cjcat.stardustextended.actions;

import openfl.utils.Function;
import idv.cjcat.stardustextended.easing.EasingFunctionType;
import idv.cjcat.stardustextended.easing.Linear;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Alters a particle's alpha value according to its `life` property.
 *
 * <p>
 * The alpha transition is applied using the easing functions designed by Robert Penner.
 * These functions can be found in the `idv.cjcat.stardust.common.easing` package.
 * </p>
 */
// [Deprecated(message="use ColorGradient instead")]
class AlphaCurve extends Action {
	/**
	 * The initial alpha value of a particle.
	 */
	public var inAlpha:Float;

	/**
	 * The final alpha value of a particle.
	 */
	public var outAlpha:Float;

	/**
	 * The transition lifespan of alpha value from the initial alpha to the normal alpha.
	 */
	public var inLifespan:Float;

	/**
	 * The transition lifespan of alpha value from the normal alpha to the final alpha.
	 */
	public var outLifespan:Float;

	private var _inFunction:Function;
	private var _outFunction:Function;
	private var _inFunctionExtraParams:Array<Float>;
	private var _outFunctionExtraParams:Array<Float>;

	public function new(inLifespan:Float = 1, outLifespan:Float = 1, inFunction:Function = null, outFunction:Function = null) {
		super();
		this.inAlpha = 0;
		this.outAlpha = 0;
		this.inLifespan = inLifespan;
		this.outLifespan = outLifespan;
		this.inFunction = inFunction;
		this.outFunction = outFunction;
		this.inFunctionExtraParams = [];
		this.outFunctionExtraParams = [];
	}

	override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		if ((particle.initLife - particle.life) < inLifespan) {
			if (_inFunction != null) {
				particle.alpha = _inFunction(particle.initLife - particle.life, inAlpha, particle.initAlpha - inAlpha, inLifespan, _inFunctionExtraParams);
			} else {
				particle.alpha = Linear.easeIn(particle.initLife - particle.life, inAlpha, particle.initAlpha - inAlpha, inLifespan);
			}
		} else if (particle.life < outLifespan) {
			if (_outFunction != null) {
				particle.alpha = _outFunction(outLifespan - particle.life, particle.initAlpha, outAlpha - particle.initAlpha, outLifespan,
					_outFunctionExtraParams);
			} else {
				particle.alpha = Linear.easeOut(outLifespan - particle.life, particle.initAlpha, outAlpha - particle.initAlpha, outLifespan);
			}
		} else {
			particle.alpha = particle.initAlpha;
		}
	}

	/**
	 * Some easing functions take more than four parameters. This property specifies those extra parameters passed to the `inFunction`.
	 */
	public var inFunctionExtraParams(get, set):Array<Float>;

	private function get_inFunctionExtraParams():Array<Float> {
		return _inFunctionExtraParams;
	}

	private function set_inFunctionExtraParams(value:Array<Float>):Array<Float> {
		if (value == null)
			value = [];
		_inFunctionExtraParams = value;
		return value;
	}

	/**
	 * Some easing functions take more than four parameters. This property specifies those extra parameters passed to the `outFunction`.
	 */
	public var outFunctionExtraParams(get, set):Array<Float>;

	private function get_outFunctionExtraParams():Array<Float> {
		return _outFunctionExtraParams;
	}

	private function set_outFunctionExtraParams(value:Array<Float>):Array<Float> {
		if (value == null)
			value = [];
		_outFunctionExtraParams = value;
		return value;
	}

	/**
	 * The easing function from the initial alpha to the normal alpha, `Linear.easeIn` by default.
	 */
	public var inFunction(get, set):Function;

	private function get_inFunction():Function {
		return _inFunction;
	}

	private function set_inFunction(value:Function):Function {
		_inFunction = value;
		return value;
	}

	/**
	 * The easing function from the normal alpha to the final alpha, `Linear.easeOut` by default.
	 */
	public var outFunction(get, set):Function;

	private function get_outFunction():Function {
		return _outFunction;
	}

	private function set_outFunction(value:Function):Function {
		_outFunction = value;
		return value;
	}

	// XML
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "AlphaCurve";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("inAlpha", Std.string(inAlpha));
		xml.set("outAlpha", Std.string(outAlpha));
		xml.set("inLifespan", Std.string(inLifespan));
		xml.set("outLifespan", Std.string(outLifespan));
		if (_inFunction != null) {
			xml.set("inFunction", EasingFunctionType.functions[_inFunction]);
		}
		if (_outFunction != null) {
			xml.set("outFunction", EasingFunctionType.functions[_outFunction]);
		}
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("inAlpha"))
			inAlpha = Std.parseFloat(xml.get("inAlpha"));
		if (xml.exists("outAlpha"))
			outAlpha = Std.parseFloat(xml.get("outAlpha"));
		if (xml.exists("inLifespan"))
			inLifespan = Std.parseFloat(xml.get("inLifespan"));
		if (xml.exists("outLifespan"))
			outLifespan = Std.parseFloat(xml.get("outLifespan"));
		if (xml.exists("inFunction"))
			inFunction = EasingFunctionType.functions[xml.get("inFunction")];
		if (xml.exists("outFunction"))
			outFunction = EasingFunctionType.functions[xml.get("outFunction")];
	}

	//------------------------------------------------------------------------------------------------
	// end of XML
}
