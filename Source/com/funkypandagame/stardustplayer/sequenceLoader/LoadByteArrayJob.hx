package com.funkypandagame.stardustplayer.sequenceLoader;

import openfl.errors.Error;
import openfl.display.DisplayObject;
import openfl.display.Loader;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.utils.ByteArray;

class LoadByteArrayJob extends EventDispatcher {
	public var byteArray(get, never):ByteArray;
	public var content(get, never):DisplayObject;

	private var _data:ByteArray;
	private var _loader:Loader;

	public var jobName:String;
	public var fileName:String;

	public function new(jobName:String, fileName:String, data:ByteArray) {
		super();
		_loader = new Loader();
		_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
		_data = data;
		this.jobName = jobName;
		this.fileName = fileName;
	}

	public function load():Void {
		_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
		_loader.loadBytes(_data);
	}

	private function onLoadComplete(event:Event):Void {
		_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
		dispatchEvent(new Event(Event.COMPLETE));
	}

	private function get_byteArray():ByteArray {
		return _data;
	}

	private function get_content():DisplayObject {
		return _loader.content;
	}

	public function destroy():Void {
		try {
			_loader.unloadAndStop();
		} catch (err:Error) {}
		_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
		_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
		_data = null;
		_loader = null;
		jobName = null;
		fileName = null;
	}

	private function onError(event:IOErrorEvent):Void {
		trace("Stardust sim loader: Error loading simulation", event);
	}
}
