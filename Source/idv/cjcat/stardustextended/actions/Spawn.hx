package idv.cjcat.stardustextended.actions;

import openfl.Vector;
import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.actions.triggers.DeathTrigger;
import idv.cjcat.stardustextended.actions.triggers.Trigger;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * Spawns new particles at the position of existing particles.
 * This action can be used to create effects such as fireworks, rocket trails, etc.
 *
 * You must specify an emitter that will emit the new particles. This action offsets the emitters newly created
 * particles position to the position this emitters particles.
 * You should set the spawner emitter's active property to false so it does not emit particles by itself.
 * Furthermore to spawn particles you need to add a trigger to this action.
 */
class Spawn extends Action {
	public var spawnerEmitter(get, set):Emitter;
	public var spawnerEmitterId(get, never):String;
	public var trigger(get, set):Trigger;

	public var inheritDirection:Bool;
	public var inheritVelocity:Bool;

	private var _spawnerEmitter:Emitter;
	private var _spawnerEmitterId:String;
	private var _trigger:Trigger;

	public function new(inheritDirection:Bool = true, inheritVelocity:Bool = false, trigger:Trigger = null) {
		super();
		priority = -10;
		this.inheritDirection = inheritDirection;
		this.inheritVelocity = inheritVelocity;
		this.trigger = trigger;
	}

	private function set_spawnerEmitter(em:Emitter):Emitter {
		_spawnerEmitter = em;
		_spawnerEmitterId = (em != null) ? em.name : null;
		return em;
	}

	private function get_spawnerEmitter():Emitter {
		return _spawnerEmitter;
	}

	private function get_spawnerEmitterId():String {
		return _spawnerEmitterId;
	}

	private function get_trigger():Trigger {
		return _trigger;
	}

	private function set_trigger(value:Trigger):Trigger {
		if (value == null) {
			value = new DeathTrigger();
		}
		_trigger = value;
		return value;
	}

	override public function update(emitter:Emitter, particle:Particle, timeDelta:Float, currentTime:Float):Void {
		if (_spawnerEmitter == null) {
			return;
		}
		if (_trigger.testTrigger(emitter, particle, timeDelta)) {
			var p:Particle;
			var newParticles:Vector<Particle> = _spawnerEmitter.createParticles(_spawnerEmitter.clock.getTicks(timeDelta));
			var len:Int = newParticles.length;
			for (m in 0...len) {
				p = newParticles[m];
				p.x += particle.x;
				p.y += particle.y;
				if (inheritVelocity) {
					p.vx += particle.vx;
					p.vy += particle.vy;
				}
				if (inheritDirection) {
					p.rotation += particle.rotation;
				}
			}
		}
	}

	// Xml
	//------------------------------------------------------------------------------------------------

	override public function getXMLTagName():String {
		return "Spawn";
	}

	override public function getRelatedObjects():Vector<StardustElement> {
		return new Vector<StardustElement>([_trigger]);
	}

	override public function toXML():Xml {
		var xml:Xml = super.toXML();

		xml.set("inheritDirection", Std.string(inheritDirection));
		xml.set("inheritVelocity", Std.string(inheritVelocity));
		xml.set("trigger", _trigger.name);

		if (_spawnerEmitter != null) {
			xml.set("spawnerEmitter", _spawnerEmitter.name);
		}

		return xml;
	}

	override public function parseXML(xml:Xml, builder:XMLBuilder = null):Void {
		super.parseXML(xml, builder);

		inheritDirection = (xml.get("inheritDirection") == "true");
		inheritVelocity = (xml.get("inheritVelocity") == "true");

		if (xml.exists("spawnerEmitter")) {
			_spawnerEmitterId = xml.get("spawnerEmitter");
		}
		_trigger = try cast(builder.getElementByName(xml.get("trigger")), Trigger) catch (e:Dynamic) null;
	}
}
