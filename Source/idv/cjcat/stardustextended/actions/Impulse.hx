package idv.cjcat.stardustextended.actions;

import openfl.Vector;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.fields.Field;
import idv.cjcat.stardustextended.fields.UniformField;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;

/**
 * Applies an instant acceleration to particles based on the <code>field</code> property.
 *
 * @see idv.cjcat.stardustextended.fields.Field
 */
class Impulse extends Action {
	public var field(get, set):Field;

	private var _field:Field;

	public function new(field:Field = null) {
		super();
		this.field = field;
		_discharged = true;
	}

	private function get_field():Field {
		return _field;
	}

	private function set_field(value:Field):Field {
		if (value == null) {
			value = new UniformField(0, 0);
		}
		_field = value;
		return value;
	}

	private var _discharged:Bool;

	/**
	 * Applies an instant acceleration to particles based on the <code>field</code> property.
	 */
	public function impulse():Void {
		_discharged = false;
	}

	override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		if (_discharged) {
			return;
		}
		var md2D:MotionData2D = field.getMotionData2D(particle);
		particle.vx += md2D.x * timeDelta;
		particle.vy += md2D.y * timeDelta;
		MotionData2DPool.recycle(md2D);
	}

	inline final override public function postUpdate(emitter:Emitter, time:Float):Void {
		_discharged = true;
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getRelatedObjects():Vector<StardustElement> {
		return new Vector<StardustElement>([_field]);
	}

	override public function getXMLTagName():String {
		return "Impulse";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("field", field.name);

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.exists("field")) {
			field = try cast(builder.getElementByName(xml.get("field")), Field) catch (e:Dynamic) null;
		}
	}
}
