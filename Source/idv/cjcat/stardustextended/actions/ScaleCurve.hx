package idv.cjcat.stardustextended.actions;

import haxe.Constraints.Function;
import idv.cjcat.stardustextended.easing.EasingFunctionType;
import idv.cjcat.stardustextended.easing.Linear;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Alters a particle's scale according to its <code>life</code> property.
 *
 * <p>
 * The scale transition is applied using the easing functions designed by Robert Penner.
 * These functions can be found in the <code>idv.cjcat.stardust.common.easing</code> package.
 * </p>
 */
class ScaleCurve extends Action {
	public var inFunctionExtraParams(get, set):Array<Dynamic>;
	public var outFunctionExtraParams(get, set):Array<Dynamic>;
	public var inFunction(get, set):Function;
	public var outFunction(get, set):Function;

	/**
	 * The initial scale of a particle, 0 by default.
	 */
	public var inScale:Float;

	/**
	 * The final scale of a particle, 0 by default.
	 */
	public var outScale:Float;

	/**
	 * The transition lifespan of scale from the initial scale to the normal scale.
	 */
	public var inLifespan:Float;

	/**
	 * The transition lifespan of scale from the normal scale to the final scale.
	 */
	public var outLifespan:Float;

	private var _inFunction:Function;
	private var _outFunction:Function;
	private var _inFunctionExtraParams:Array<Dynamic>;
	private var _outFunctionExtraParams:Array<Dynamic>;

	public function new(inLifespan:Float = 0, outLifespan:Float = 0, inFunction:Function = null, outFunction:Function = null) {
		super();
		this.inScale = 0;
		this.outScale = 0;
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
				particle.scale = Reflect.callMethod(null, _inFunction, [
					particle.initLife - particle.life,
					inScale,
					particle.initScale - inScale,
					inLifespan
				].concat(_inFunctionExtraParams));
			} else {
				particle.scale = Linear.easeIn(particle.initLife - particle.life, inScale, particle.initScale - inScale, inLifespan);
			}
		} else if (particle.life < outLifespan) {
			if (_outFunction != null) {
				particle.scale = Reflect.callMethod(null, _outFunction, [
					outLifespan - particle.life,
					particle.initScale,
					outScale - particle.initScale,
					outLifespan
				].concat(_outFunctionExtraParams));
			} else {
				particle.scale = Linear.easeOut(outLifespan - particle.life, particle.initScale, outScale - particle.initScale, outLifespan);
			}
		} else {
			particle.scale = particle.initScale;
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
	 * The easing function from the initial scale to the normal scale, <code>Linear.easeIn</code> by default.
	 */
	private function get_inFunction():Function {
		return _inFunction;
	}

	private function set_inFunction(value:Function):Function {
		_inFunction = value;
		return value;
	}

	/**
	 * The easing function from the normal scale to the final scale, <code>Linear.easeOut</code> by default.
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
		return "ScaleCurve";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.setAttribute("inScale", inScale);
		xml.setAttribute("outScale", outScale);
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

		if (xml.att.inScale.length()) {
			inScale = as3hx.Compat.parseFloat(xml.att.inScale);
		}
		if (xml.att.outScale.length()) {
			outScale = as3hx.Compat.parseFloat(xml.att.outScale);
		}
		if (xml.att.inLifespan.length()) {
			inLifespan = as3hx.Compat.parseFloat(xml.att.inLifespan);
		}
		if (xml.att.outLifespan.length()) {
			outLifespan = as3hx.Compat.parseFloat(xml.att.outLifespan);
		}
		if (xml.att.inFunction.length()) {
			inFunction = EasingFunctionType.functions[Std.string(xml.att.inFunction)];
		}
		if (xml.att.outFunction.length()) {
			outFunction = EasingFunctionType.functions[Std.string(xml.att.outFunction)];
		}
	}
}
