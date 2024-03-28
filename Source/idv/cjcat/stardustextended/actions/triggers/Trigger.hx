package idv.cjcat.stardustextended.actions.triggers;

import openfl.errors.Error;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;

class Trigger extends StardustElement {
	public function testTrigger(emitter:Emitter, particle:Particle, time:Float):Bool {
		throw new Error("This method must be overridden");
	}

	// Xml
	//------------------------------------------------------------------------------------------------
	override public function getXMLTagName():String {
		throw new Error("This method must be overridden");
	}

	override public function getElementTypeXMLTag():Xml {
		return Xml.parse("<triggers/>");
	}

	public function new() {
		super();
	}
}
