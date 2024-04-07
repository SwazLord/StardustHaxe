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
	public var inFunctionExtraParams(get, set):Array<Float>;
	public var outFunctionExtraParams(get, set):Array<Float>;
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
	private var _inFunctionExtraParams:Array<Float>;
	private var _outFunctionExtraParams:Array<Float>;

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
	private function get_inFunctionExtraParams():Array<Float> {
		return _inFunctionExtraParams;
	}

	private function set_inFunctionExtraParams(value:Array<Float>):Array<Float> {
		if (value == null) {
			value = [];
		}
		_inFunctionExtraParams = value;
		return value;
	}

	/**
	 * Some easing functions take more than four parameters. This property specifies those extra parameters passed to the <code>outFunction</code>.
	 */
	private function get_outFunctionExtraParams():Array<Float> {
		return _outFunctionExtraParams;
	}

	private function set_outFunctionExtraParams(value:Array<Float>):Array<Float> {
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

		xml.set("inScale", Std.string(inScale));
		xml.set("outScale", Std.string(outScale));
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

		if (xml.exists("inScale")) {
			inScale = Std.parseFloat(xml.get("inScale"));
		}
		if (xml.exists("outScale")) {
			outScale = Std.parseFloat(xml.get("outScale"));
		}
		if (xml.exists("inLifespan")) {
			inLifespan = Std.parseFloat(xml.get("inLifespan"));
		}
		if (xml.exists("outLifespan")) {
			outLifespan = Std.parseFloat(xml.get("outLifespan"));
		}
		if (xml.exists("inFunction")) {
			inFunction = EasingFunctionType.functions[Std.string(xml.get("inFunction"))];
		}
		if (xml.exists("outFunction")) {
			outFunction = EasingFunctionType.functions[Std.string(xml.get("outFunction"))];
		}
	}
}
