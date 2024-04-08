package idv.cjcat.stardustextended.actions;

import openfl.Vector;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.fields.Field;
import idv.cjcat.stardustextended.fields.UniformField;
import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Applies accelerations to particles according to the associated gravity fields, in pixels.
 * @see idv.cjcat.stardustextended.fields.Field
 */
class Gravity extends Action implements IFieldContainer {
	private var _fields:Vector<Field>;

	public function new(fields:Vector<Field> = null) {
		super();
		priority = -3;
		if (fields != null) {
			_fields = fields;
		} else {
			_fields = new Vector<Field>();
			_fields.push(new UniformField(0, 1));
		}
	}

	public var fields(get, set):Vector<Field>;

	public function get_fields():Vector<Field> {
		return _fields;
	}

	public function set_fields(value:Vector<Field>):Vector<Field> {
		return _fields = value;
	}

	/**
	 * Adds a gravity field to the simulation.
	 * @param field
	 */
	public function addField(field:Field):Void {
		if (_fields.indexOf(field) < 0)
			_fields.push(field);
	}

	/**
	 * Removes a gravity field from the simulation.
	 * @param field
	 */
	public function removeField(field:Field):Void {
		var index:Int = _fields.indexOf(field);
		if (index >= 0)
			_fields.splice(index, 1);
	}

	/**
	 * Removes all gravity fields from the simulation.
	 */
	public function clearFields():Void {
		_fields = new Vector<Field>();
	}

	private var _updateMd2D:MotionData2D;
	private var _ui:Int;
	private var _uLen:UInt;

	override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		timeDelta = timeDelta * 100; // acceleration is in m/(s*s)
		_uLen = _fields.length;
		for (_ui in 0..._uLen) {
			_updateMd2D = _fields[_ui].getMotionData2D(particle);

			if (_updateMd2D != null) {
				particle.vx += _updateMd2D.x * timeDelta;
				particle.vy += _updateMd2D.y * timeDelta;
				MotionData2DPool.recycle(_updateMd2D);
			}
		}
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getRelatedObjects():Vector<StardustElement> {
		return cast _fields;
	}

	override public function getXMLTagName():String {
		return "Gravity";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		if (_fields.length > 0) {
			var fieldsXml:Xml = Xml.createElement("fields");
			xml.addChild(fieldsXml);
			for (field in _fields) {
				fieldsXml.addChild(field.getXMLTag());
			}
		}

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);
		clearFields();

		for (node in xml.elementsNamed("fields").next().elements()) {
			addField(cast(builder.getElementByName(node.get("name")), Field));
		}
	}

	//------------------------------------------------------------------------------------------------
	// end of Xml
}
