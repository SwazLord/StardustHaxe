package idv.cjcat.stardustextended.actions;

import haxe.Constraints.Function;
import idv.cjcat.stardustextended.easing.EasingFunctionType;
import idv.cjcat.stardustextended.easing.Linear;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Alters a particle's alpha value according to its <code>life</code> property.
 *
 * <p>
 * The alpha transition is applied using the easing functions designed by Robert Penner.
 * These functions can be found in the <code>idv.cjcat.stardust.common.easing</code> package.
 * </p>
 */
// [Deprecated(message="use ColorGradient instead")]
class AlphaCurve extends Action {
	public var inFunctionExtraParams(get, set):Array<Dynamic>;
	public var outFunctionExtraParams(get, set):Array<Dynamic>;
	public var inFunction(get, set):Function;
	public var outFunction(get, set):Function;

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
	private var _inFunctionExtraParams:Array<Dynamic>;
	private var _outFunctionExtraParams:Array<Dynamic>;

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

	inline final override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		if ((particle.initLife - particle.life) < inLifespan) {
			if (_inFunction != null) {
				particle.alpha = Reflect.callMethod(null, _inFunction, [
					particle.initLife - particle.life,
					inAlpha,
					particle.initAlpha - inAlpha,
					inLifespan
				].concat(_inFunctionExtraParams));
			} else {
				particle.alpha = Linear.easeIn(particle.initLife - particle.life, inAlpha, particle.initAlpha - inAlpha, inLifespan);
			}
		} else if (particle.life < outLifespan) {
			if (_outFunction != null) {
				particle.alpha = Reflect.callMethod(null, _outFunction, [
					outLifespan - particle.life,
					particle.initAlpha,
					outAlpha - particle.initAlpha,
					outLifespan
				].concat(_outFunctionExtraParams));
			} else {
				particle.alpha = Linear.easeOut(outLifespan - particle.life, particle.initAlpha, outAlpha - particle.initAlpha, outLifespan);
			}
		} else {
			particle.alpha = particle.initAlpha;
		}
	}

	/**
	 * Some easing functions take more than four parameters. This property specifies those extra parameters passed to the <code>inFunction</code>.
	 */
	private function get_inFunctionExtraParams():Array<Dynamic> {
		return _inFunctionExtraParams;
	}

	private function set_inFunctionExtraParams(value:Array<Dynamic>):Array<Dynamic> {
		if (value == null) {
			value = [];
		}
		_inFunctionExtraParams = value;
		return value;
	}

	/**
	 * Some easing functions take more than four parameters. This property specifies those extra parameters passed to the <code>outFunction</code>.
	 */
	private function get_outFunctionExtraParams():Array<Dynamic> {
		return _outFunctionExtraParams;
	}

	private function set_outFunctionExtraParams(value:Array<Dynamic>):Array<Dynamic> {
		if (value == null) {
			value = [];
		}
		_outFunctionExtraParams = value;
		return value;
	}

	/**
	 * The easing function from the initial alpha to the normal alpha, <code>Linear.easeIn</code> by default.
	 */
	private function get_inFunction():Function {
		return _inFunction;
	}

	private function set_inFunction(value:Function):Function {
		_inFunction = value;
		return value;
	}

	/**
	 * The easing function from the normal alpha to the final alpha, <code>Linear.easeOut</code> by default.
	 */
	private function get_outFunction():Function {
		return _outFunction;
	}

	private function set_outFunction(value:Function):Function {
		_outFunction = value;
		return value;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "AlphaCurve";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.setAttribute("inAlpha", inAlpha);
		xml.setAttribute("outAlpha", outAlpha);
		xml.setAttribute("inLifespan", inLifespan);
		xml.setAttribute("outLifespan", outLifespan);
		if (_inFunction != null) {
			xml.setAttribute("inFunction", EasingFunctionType.functions[_inFunction]);
		}
		if (_outFunction != null) {
			xml.setAttribute("outFunction", EasingFunctionType.functions[_outFunction]);
		}
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.att.inAlpha.length()) {
			inAlpha = Std.parseFloat(xml.att.inAlpha);
		}
		if (xml.att.outAlpha.length()) {
			outAlpha = Std.parseFloat(xml.att.outAlpha);
		}
		if (xml.att.inLifespan.length()) {
			inLifespan = Std.parseFloat(xml.att.inLifespan);
		}
		if (xml.att.outLifespan.length()) {
			outLifespan = Std.parseFloat(xml.att.outLifespan);
		}
		if (xml.att.inFunction.length()) {
			inFunction = EasingFunctionType.functions[Std.string(xml.att.inFunction)];
		}
		if (xml.att.outFunction.length()) {
			outFunction = EasingFunctionType.functions[Std.string(xml.att.outFunction)];
		}
	}
}
