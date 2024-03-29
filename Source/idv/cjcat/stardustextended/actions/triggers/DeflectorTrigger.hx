package idv.cjcat.stardustextended.actions.triggers;

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.deflectors.Deflector;

class DeflectorTrigger extends Trigger {
	public var deflector:Deflector;

	public function new(deflector:Deflector = null) {
		super();
		this.deflector = deflector;
	}

	override public function testTrigger(emitter:Emitter, particle:Particle, time:Float):Bool {
		return cast(particle.dictionary[deflector], Bool);
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getRelatedObjects():Array<StardustElement> {
		return [deflector];
	}

	override public function getXMLTagName():String {
		return "DeflectorTrigger";
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();
		if (deflector != null) {
			xml.set("deflector", Std.string(deflector.name));
		}
		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		if (xml.att.deflector.length()) {
			deflector = try cast(builder.getElementByName(xml.att.deflector), Deflector) catch (e:Dynamic) null;
		}
	}
}
