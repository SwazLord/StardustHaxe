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

import openfl.utils.ByteArray;
import openfl.utils.IDataOutput;

/**
 *
 * @author Roland Zwaga
 */
interface IZipFile {
	var content(get, set):ByteArray;

	var date(get, set):Date;

	var filename(get, set):String;
	var sizeCompressed(get, never):Int;
	var sizeUncompressed(get, never):Int;
	var versionNumber(get, never):String;

	function getContentAsString(recompress:Bool = true, charset:String = "utf-8"):String;
	function serialize(stream:IDataOutput, includeAdler32:Bool, centralDir:Bool = false, centralDirOffset:Int = 0):Int;
	function setContent(data:ByteArray, doCompress:Bool = true):Void;
	function setContentAsString(value:String, charset:String = "utf-8", doCompress:Bool = true):Void;
}
