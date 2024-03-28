package idv.cjcat.stardustextended.actions;

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
	private var _fields:Array<Field>;

	public function new(fields:Array<Field> = null) {
		priority = -3;
		if (fields) {
			_fields = fields;
		} else {
			_fields = new Array<Field>();
			_fields.push(new UniformField(0, 1));
		}
	}

	public var fields(get, set):Array<Field>;

	public function get_fields():Array<Field> {
		return _fields;
	}

	public function set_fields(value:Array<Field>):Array<Field> {
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
			_fields.removeAt(index);
	}

	/**
	 * Removes all gravity fields from the simulation.
	 */
	public function clearFields():Void {
		_fields = new Array<Field>();
	}

	private var _updateMd2D:MotionData2D;
	private var _ui:Int;
	private var _uLen:UInt;

	override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		timeDelta = timeDelta * 100; // acceleration is in m/(s*s)
		_uLen = _fields.length;
		for (_ui in 0..._uLen) {
			_updateMd2D = _fields[_ui].getMotionData2D(particle);

			if (_updateMd2D) {
				particle.vx += _updateMd2D.x * timeDelta;
				particle.vy += _updateMd2D.y * timeDelta;
				MotionData2DPool.recycle(_updateMd2D);
			}
		}
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getRelatedObjects():Array<StardustElement> {
		return Array<StardustElement>(_fields);
	}

	override public function getXMLTagName():String {
		return "Gravity";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		if (_fields.length > 0) {
			xml.appendChild(<fields/>);
			var field:Field;
			for (field in _fields) {
				xml.fields.appendChild(field.getXMLTag());
			}
		}

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);
		var access = new haxe.xml.Access(xml);
		clearFields();
		for (node in access.node.fields.element) {
			addField(cast(builder.getElementByName(node.att.name), Field));
		}
	}

	//------------------------------------------------------------------------------------------------
	// end of Xml
}
