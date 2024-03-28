package idv.cjcat.stardustextended.actions;

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.fields.Field;
import idv.cjcat.stardustextended.fields.UniformField;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;

/**
 * Alters a particle's velocity based on a vector field.
 *
 * <p>
 * The returned value of a field is a <code>MotionData2D</code> object, which is a 2D value class.
 * The particle's velocity X and Y components are set to the <code>MotionData2D</code> object's <code>x</code> and <code>y</code> properties, respectively.
 * </p>
 *
 * <p>
 * Default priority = -2;
 * </p>
 */
class VelocityField extends Action implements IFieldContainer {
	public var fields(get, set):Array<Field>;

	private var field:Field;

	public function new(_field:Field = null) {
		super();
		priority = -2;
		if (field != null) {
			field = _field;
		} else {
			field = new UniformField(100, 100);
		}
	}

	private function get_fields():Array<Field> {
		if (field != null) {
			return [field];
		}
		return new Array<Field>();
	}

	private function set_fields(value:Array<Field>):Array<Field> {
		if (value != null && value.length > 0) {
			field = value[0];
		} else {
			field = null;
		}
		return value;
	}

	override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		if (field == null) {
			return;
		}
		var md2D:MotionData2D = field.getMotionData2D(particle);
		particle.vx = md2D.x;
		particle.vy = md2D.y;
		MotionData2DPool.recycle(md2D);
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getRelatedObjects():Array<StardustElement> {
		return [field];
	}

	override public function getXMLTagName():String {
		return "VelocityField";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		if (field == null) {
			xml.setAttribute("field", "null");
		} else {
			xml.setAttribute("field", field.name);
		}

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.att.field == "null") {
			field = null;
		} else if (xml.att.field.length()) {
			field = try cast(builder.getElementByName(xml.att.field), Field) catch (e:Dynamic) null;
		}
	}
}
