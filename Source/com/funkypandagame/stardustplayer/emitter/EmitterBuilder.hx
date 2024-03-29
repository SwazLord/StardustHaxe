package com.funkypandagame.stardustplayer.emitter;
import idv.cjcat.stardustextended.CommonClassPackage;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.xml.XMLBuilder;
import idv.cjcat.stardustextended.handlers.starling.StarlingHandler;

class EmitterBuilder {
	private static var _builder:XMLBuilder;

	public static function buildEmitter(sourceXML:Xml, uniqueEmitterId:String):Emitter {
		createBuilderIfNeeded();
		_builder.buildFromXML(sourceXML);
		var emitter:Emitter = cast _builder.getElementsByClass(Emitter)[0];
		emitter.name = uniqueEmitterId;
		return emitter;
	}

	/**
	 * Returns the builder that is used to parse the XML descriptor.
	 * You can use it to register new custom classes from your XML.
	 */
	public static var builder(get, never):XMLBuilder;

	private static function get_builder():XMLBuilder {
		createBuilderIfNeeded();
		return _builder;
	}

	private static function createBuilderIfNeeded():Void {
		if (_builder == null) {
			_builder = new XMLBuilder();
			_builder.registerClassesFromClassPackage(CommonClassPackage.getInstance());
			_builder.registerClass(StarlingHandler);
		}
	}
}
