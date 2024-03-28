/*
 * Copyright 2007-2012 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.as3commons.zip;

import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.events.*;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Loader;
import openfl.utils.ByteArray;

/**
 * Dispatched when all pending files have been processed.
 *
 * @eventType flash.events.Event.COMPLETE
 */
@:meta(Event(name = "complete", type = "flash.events.Event"))
/**
 * <p>ZipLibrary works with a Zip instance to load files as
 * usable instances, like a DisplayObject or BitmapData. Each file
 * from a loaded zip is processed based on their file extensions.
 * More than one Zip instance can be supplied, and if it is
 * currently loading files, then ZipLibrary will wait for incoming
 * files before it completes.</p>
 *
 * <p>Flash's built-in Loader class is used to convert formats, so the
 * only formats currently supported are ones that Loader supports.
 * As of this writing they are SWF, JPEG, GIF, and PNG.</p>
 *
 * <p>The following example loads an external zip file, outputs the
 * width and height of an image and then loads a sound from a SWF file.</p>
 *
 * <pre>
 * package {
 * 	import openfl.events.*;
 * 	import openfl.display.BitmapData;
 * 	import org.as3commons.zip.Zip;
 * 	import org.as3commons.org.ZipLibrary;
 *
 * 	public class Example {
 * 		private var lib:ZipLibrary;
 *
 * 		public function Example(url:String) {
 * 			lib = new ZipLibrary();
 * 			lib.formatAsBitmapData(".gif");
 * 			lib.formatAsBitmapData(".jpg");
 * 			lib.formatAsBitmapData(".png");
 * 			lib.formatAsDisplayObject(".swf");
 * 			lib.addEventListener(Event.COMPLETE,onLoad);
 *
 * 			var zip:Zip = new Zip();
 * 			zip.load(url);
 * 			lib.addZip(zip);
 * 		}
 * 		private function onLoad(evt:Event) {
 * 			var image:BitmapData = lib.getBitmapData("test.png");
 * 			trace("Size: " + image.width + "x" + image.height);
 *
 * 			var importedSound:Class = lib.getDefinition("data.swf", "SoundClass") as Class;
 * 			var snd:Sound = new importedSound() as Sound;
 * 		}
 * 	}
 * }</pre>
 *
 * @see http://livedocs.macromedia.com/flex/201/langref/flash/display/Loader.html
 *
 * @author Claus Wahlers
 * @author Max Herkender
 */
class ZipLibrary extends EventDispatcher implements IZipLibrary {
	private static var FORMAT_BITMAPDATA:Int = (1 << 0);
	private static var FORMAT_DISPLAYOBJECT:Int = (1 << 1);

	private var pendingFiles:Array<Dynamic> = [];
	private var pendingZips:Array<Dynamic> = [];
	private var currentState:Int = 0;
	private var currentFilename:String;
	private var currentZip:Zip;
	private var currentLoader:Loader;
	private var bitmapDataFormat:EReg = ~/[]/;
	private var displayObjectFormat:EReg = ~/[]/;
	private var bitmapDataList:Dynamic = {};
	private var displayObjectList:Dynamic = {};

	/**
	 * Constructor
	 */
	public function new() {
		super();
	}

	/**
	 * Use this method to add an Zip instance to the processing queue.
	 * If the Zip instance specified is not active (currently receiving files)
	 * when it is processed than only the files already loaded will be processed.
	 *
	 * @param zip An Zip instance to process
	 */
	public function addZip(zip:IZip):Void {
		pendingZips.unshift(zip);
		processNext();
	}

	/**
	 * Used to indicate a file extension that triggers formatting to BitmapData.
	 *
	 * @param ext A file extension (".jpg", ".png", etc)
	 */
	public function formatAsBitmapData(ext:String):Void {
		bitmapDataFormat = addExtension(bitmapDataFormat, ext);
	}

	/**
	 * Used to indicate a file extension that triggers formatting to DisplayObject.
	 *
	 * @param ext A file extension (".swf", ".png", etc)
	 */
	public function formatAsDisplayObject(ext:String):Void {
		displayObjectFormat = addExtension(displayObjectFormat, ext);
	}

	/**
	 * @private
	 */
	private function addExtension(original:EReg, ext:String):EReg {
		var pattern:EReg = ~/[^A-Za-z0-9]/;
		var replacement:String = "\\$&";
		var result:String = pattern.replace(ext, replacement);
		return new EReg(result + "$|" + original, "");
	}

	/**
	 * Request a file that has been formatted as BitmapData.
	 * A ReferenceError is thrown if the file does not exist as a
	 * BitmapData.
	 *
	 * @param filename The filename of the BitmapData instance.
	 */
	public function getBitmapData(filename:String):BitmapData {
		if (Std.is(!Reflect.field(bitmapDataList, filename), BitmapData)) {
			throw new ArgumentError("File \"" + filename + "\" was not found as a BitmapData");
		}
		return try cast(Reflect.field(bitmapDataList, filename), BitmapData) catch (e:Dynamic) null;
	}

	/**
	 * Request a file that has been formatted as a DisplayObject.
	 * A ReferenceError is thrown if the file does not exist as a
	 * DisplayObject.
	 *
	 * @param filename The filename of the DisplayObject instance.
	 */
	public function getDisplayObject(filename:String):DisplayObject {
		if (!displayObjectList.exists(filename)) {
			throw new ArgumentError("File \"" + filename + "\" was not found as a DisplayObject");
		}
		return try cast(Reflect.field(displayObjectList, filename), DisplayObject) catch (e:Dynamic) null;
	}

	/**
	 * Retrieve a definition (like a class) from a SWF file that has
	 * been formatted as a DisplayObject.
	 * A ReferenceError is thrown if the file does not exist as a
	 * DisplayObject, or the definition does not exist.
	 *
	 * @param filename The filename of the DisplayObject instance.
	 */
	public function getDefinition(filename:String, definition:String):Dynamic {
		if (!displayObjectList.exists(filename)) {
			throw new ArgumentError("File \"" + filename + "\" was not found as a DisplayObject, ");
		}
		var disp:DisplayObject = try cast(Reflect.field(displayObjectList, filename), DisplayObject) catch (e:Dynamic) null;
		try {
			return disp.loaderInfo.applicationDomain.getDefinition(definition);
		} catch (e:Error) {
			throw new ArgumentError("Definition \"" + definition + "\" in file \"" + filename + "\" could not be retrieved: " + e.message);
		}
		return null;
	}

	/**
	 * @private
	 */
	private function processNext(evt:Event = null):Void {
		while (currentState == 0) {
			if (pendingFiles.length > 0) {
				var nextFile:ZipFile = pendingFiles.pop();
				if (bitmapDataFormat.match(nextFile.filename)) {
					currentState = currentState | FORMAT_BITMAPDATA;
				}
				if (displayObjectFormat.match(nextFile.filename)) {
					currentState = currentState | FORMAT_DISPLAYOBJECT;
				}
				if ((currentState & Std.int(FORMAT_BITMAPDATA | FORMAT_DISPLAYOBJECT)) != 0) {
					currentFilename = nextFile.filename;
					currentLoader = new Loader();
					currentLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
					currentLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loaderCompleteHandler);
					var content:ByteArray = nextFile.content;
					content.position = 0;
					currentLoader.loadBytes(content);
					break;
				}
			} else if (currentZip == null) {
				if (pendingZips.length > 0) {
					currentZip = pendingZips.pop();
					var i:Int = currentZip.getFileCount();
					while (i > 0) {
						pendingFiles.push(currentZip.getFileAt(--i));
					}
					if (currentZip.active) {
						currentZip.addEventListener(Event.COMPLETE, zipCompleteHandler);
						currentZip.addEventListener(ZipEvent.FILE_LOADED, fileCompleteHandler);
						currentZip.addEventListener(ZipErrorEvent.PARSE_ERROR, zipCompleteHandler);
						break;
					} else {
						currentZip = null;
					}
				} else {
					dispatchEvent(new Event(Event.COMPLETE));
					break;
				}
			} else {
				break;
			}
		}
	}

	/**
	 * @private
	 */
	private function loaderCompleteHandler(evt:Event):Void {
		if ((currentState & FORMAT_BITMAPDATA) == FORMAT_BITMAPDATA) {
			if (Std.is(currentLoader.content, Bitmap)
				&& Std.is((try cast(currentLoader.content, Bitmap) catch (e:Dynamic) null).bitmapData, BitmapData)) {
				var bitmapData:BitmapData = (try cast(currentLoader.content, Bitmap) catch (e:Dynamic) null).bitmapData;
				Reflect.setField(bitmapDataList, currentFilename, bitmapData.clone());
			} else if (Std.is(currentLoader.content, DisplayObject)) {
				var width:Int = Std.int(currentLoader.content.width);
				var height:Int = Std.int(currentLoader.content.height);
				if (width != 0 && height != 0) {
					var bitmapData2:BitmapData = new BitmapData(width, height, true, 0x00000000);
					bitmapData2.draw(currentLoader);
					Reflect.setField(bitmapDataList, currentFilename, bitmapData2);
				} else {
					trace("File \"" + currentFilename + "\" could not be converted to BitmapData");
				}
			} else {
				trace("File \"" + currentFilename + "\" could not be converted to BitmapData");
			}
		}
		if ((currentState & FORMAT_DISPLAYOBJECT) == FORMAT_DISPLAYOBJECT) {
			if (Std.is(currentLoader.content, DisplayObject)) {
				// trace(currentFilename+" -> DisplayObject");{
				Reflect.setField(displayObjectList, currentFilename, currentLoader.content);
			} else {
				currentLoader.unload();
				trace("File \"" + currentFilename + "\" could not be loaded as a DisplayObject");
			}
		} else {
			currentLoader.unload();
		}
		currentLoader = null;
		currentFilename = "";
		currentState = currentState & Std.int(~(FORMAT_BITMAPDATA | FORMAT_DISPLAYOBJECT));
		processNext();
	}

	/**
	 * @private
	 */
	private function fileCompleteHandler(evt:ZipEvent):Void {
		pendingFiles.unshift(evt.file);
		processNext();
	}

	/**
	 * @private
	 */
	private function zipCompleteHandler(evt:Event):Void {
		currentZip.removeEventListener(Event.COMPLETE, zipCompleteHandler);
		currentZip.removeEventListener(ZipEvent.FILE_LOADED, fileCompleteHandler);
		currentZip.removeEventListener(ZipErrorEvent.PARSE_ERROR, zipCompleteHandler);
		currentZip = null;
		processNext();
	}
}
