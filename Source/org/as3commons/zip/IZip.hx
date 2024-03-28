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

import openfl.events.IEventDispatcher;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;
import openfl.utils.IDataOutput;

/**
 *
 * @author Roland Zwaga
 */
interface IZip extends IEventDispatcher {
	var active(get, never):Bool;

	function addFile(name:String, content:ByteArray = null, doCompress:Bool = true):ZipFile;
	function addFileAt(index:Int, name:String, content:ByteArray = null, doCompress:Bool = true):ZipFile;
	function addFileFromString(name:String, content:String, charset:String = "utf-8", doCompress:Bool = true):ZipFile;
	function addFileFromStringAt(index:Int, name:String, content:String, charset:String = "utf-8", doCompress:Bool = true):ZipFile;
	function close():Void;
	function getFileAt(index:Int):IZipFile;
	function getFileByName(name:String):IZipFile;
	function getFileCount():Int;
	function load(request:URLRequest):Void;
	function loadBytes(bytes:ByteArray):Void;
	function removeFileAt(index:Int):IZipFile;
	function serialize(stream:IDataOutput, includeAdler32:Bool = false):Void;
}
