package idv.cjcat.stardustextended.actions.triggers;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * This trigger will be triggered when a particle is alive.
 */
class LifeTrigger extends Trigger {
	public var lowerBound(get, set):Float;
	public var upperBound(get, set):Float;

	/**
	 * For this trigger to work, a particle's life must also be within the lower and upper bounds when this property is set to true,
	 * or outside of the range if this property is set to false.
	 */
	public var triggerWithinBounds:Bool;

	private var _lowerBound:Float;
	private var _upperBound:Float;

	public function new(lowerBound:Float = 0, upperBound:Float = as3hx.Compat.FLOAT_MAX, triggerWithinBounds:Bool = true) {
		super();
		this.lowerBound = lowerBound;
		this.upperBound = upperBound;
		this.triggerWithinBounds = triggerWithinBounds;
	}

	final override public function testTrigger(emitter:Emitter, particle:Particle, time:Float):Bool {
		if (triggerWithinBounds) {
			if ((particle.life >= _lowerBound) && (particle.life <= _upperBound)) {
				return true;
			}
		} else if ((particle.life < _lowerBound) || (particle.life > _upperBound)) {
			return true;
		}
		return false;
	}

	/**
	 * The lower bound of effective range.
	 */
	private function get_lowerBound():Float {
		return _lowerBound;
	}

	private function set_lowerBound(value:Float):Float {
		if (value > _upperBound) {
			_upperBound = value;
		}
		_lowerBound = value;
		return value;
	}

	/**
	 * The upper bound of effective range.
	 */
	private function get_upperBound():Float {
		return _upperBound;
	}

	private function set_upperBound(value:Float):Float {
		if (value < _lowerBound) {
			_lowerBound = value;
		}
		_upperBound = value;
		return value;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "LifeTrigger";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();
		xml.setAttribute("triggerWithinBounds", triggerWithinBounds);
		xml.setAttribute("lowerBound", _lowerBound);
		xml.setAttribute("upperBound", _upperBound);
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		triggerWithinBounds = (xml.att.triggerWithinBounds == "true");
		lowerBound = as3hx.Compat.parseFloat(xml.att.lowerBound);
		upperBound = as3hx.Compat.parseFloat(xml.att.upperBound);
	}
}
