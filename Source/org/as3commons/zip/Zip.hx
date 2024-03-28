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

import openfl.net.URLRequest;
import openfl.utils.ByteArray;
import openfl.net.URLStream;
import openfl.events.EventDispatcher;
import openfl.errors.Error;
import openfl.utils.IDataInput;
import openfl.utils.Endian;
import openfl.events.ProgressEvent;
import openfl.events.SecurityErrorEvent;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.utils.IDataOutput;
import haxe.Constraints.Function;

/**
 * Dispatched when a file contained in a ZIP archive has
 * loaded successfully.
 *
 * @eventType org.as3commons.zip.ZipEvent.FILE_LOADED
 */
@:meta(Event(name = "fileLoaded", type = "org.as3commons.zip.ZipEvent"))
/**
 * Dispatched when an error is encountered while parsing a
 * ZIP Archive.
 *
 * @eventType org.as3commons.zip.ZipErrorEvent.PARSE_ERROR
 */
@:meta(Event(name = "parseError", type = "org.as3commons.zip.ZipErrorEvent"))
/**
 * Dispatched when data has loaded successfully.
 *
 * @eventType flash.events.Event.COMPLETE
 */
@:meta(Event(name = "complete", type = "flash.events.Event"))
/**
 * Dispatched if a call to Zip.load() attempts to access data
 * over HTTP, and the current Flash Player is able to detect
 * and return the status code for the request. (Some browser
 * environments may not be able to provide this information.)
 * Note that the httpStatus (if any) will be sent before (and
 * in addition to) any complete or error event
 *
 * @eventType flash.events.HTTPStatusEvent.HTTP_STATUS
 */
@:meta(Event(name = "httpStatus", type = "flash.events.HTTPStatusEvent"))
/**
 * Dispatched when an input/output error occurs that causes a
 * load operation to fail.
 *
 * @eventType flash.events.IOErrorEvent.IO_ERROR
 */
@:meta(Event(name = "ioError", type = "flash.events.IOErrorEvent"))
/**
 * Dispatched when a load operation starts.
 *
 * @eventType flash.events.Event.OPEN
 */
@:meta(Event(name = "open", type = "flash.events.Event"))
/**
 * Dispatched when data is received as the download operation
 * progresses.
 *
 * @eventType flash.events.ProgressEvent.PROGRESS
 */
@:meta(Event(name = "progress", type = "flash.events.ProgressEvent"))
/**
 * Dispatched if a call to Zip.load() attempts to load data
 * from a server outside the security sandbox.
 *
 * @eventType flash.events.SecurityErrorEvent.SECURITY_ERROR
 */
@:meta(Event(name = "securityError", type = "flash.events.SecurityErrorEvent"))
/**
 * Loads and parses ZIP archives.
 *
 * <p>Zip is able to process, create and modify standard ZIP archives as described in the
 * <a href="http://www.pkware.com/business_and_developers/developer/popups/appnote.txt">PKZIP file format documentation</a>.</p>
 *
 * <p>Limitations:</p>
 * <ul>
 * <li>ZIP feature versions &gt; 2.0 are not supported</li>
 * <li>ZIP archives containing data descriptor records are not supported.</li>
 * <li>If running in the Flash Player browser plugin, Zip requires ZIPs to be
 * patched (Adler32 checksums need to be added). This is not required if
 * Zip runs in the Adobe AIR runtime or if files contained in the ZIP
 * are not compressed.</li>
 * </ul>
 *
 * @author Claus Wahlers
 * @author Max Herkender
 */
class Zip extends EventDispatcher implements IZip {
	public var active(get, never):Bool;

	private var filesList:Array<Dynamic>;
	private var filesDict:Map<String, IZipFile>;

	private var urlStream:URLStream;
	private var charEncoding:String;
	private var parseFunc:Function;
	private var currentFile:ZipFile;

	private var ddBuffer:ByteArray;
	private var ddSignature:Int;
	private var ddCompressedSize:Int;

	// PKZIP record signatures
	public static inline var SIG_CENTRAL_FILE_HEADER:Int = 0x02014b50;
	public static inline var SIG_SPANNING_MARKER:Int = 0x30304b50;
	public static inline var SIG_LOCAL_FILE_HEADER:Int = 0x04034b50;
	public static inline var SIG_DIGITAL_SIGNATURE:Int = 0x05054b50;
	public static inline var SIG_END_OF_CENTRAL_DIRECTORY:Int = 0x06054b50;
	public static inline var SIG_ZIP64_END_OF_CENTRAL_DIRECTORY:Int = 0x06064b50;
	public static inline var SIG_ZIP64_END_OF_CENTRAL_DIRECTORY_LOCATOR:Int = 0x07064b50;
	public static inline var SIG_DATA_DESCRIPTOR:Int = 0x08074b50;
	public static inline var SIG_ARCHIVE_EXTRA_DATA:Int = 0x08064b50;
	public static inline var SIG_SPANNING:Int = 0x08074b50;

	/**
	 * Constructor
	 *
	 * @param filenameEncoding The character encoding used for filenames
	 * contained in the zip. If unspecified, unicode ("utf-8") is used.
	 * Older zips commonly use encoding "IBM437" (aka "cp437"),
	 * while other European countries use "ibm850".
	 * @see http://livedocs.adobe.com/labs/as3preview/langref/charset-codes.html
	 */
	public function new(filenameEncoding:String = "utf-8") {
		super();
		charEncoding = filenameEncoding;
		parseFunc = parseIdle;
	}

	/**
	 * Indicates whether a file is currently being processed or not.
	 */
	private function get_active():Bool {
		return (parseFunc != parseIdle);
	}

	/**
	 * Begins downloading the ZIP archive specified by the request
	 * parameter.
	 *
	 * @param request A URLRequest object specifying the URL of a ZIP archive
	 * to download.
	 * If the value of this parameter or the URLRequest.url property
	 * of the URLRequest object passed are null, Flash Player throws
	 * a null pointer error.
	 */
	public function load(request:URLRequest):Void {
		if (urlStream == null && parseFunc == parseIdle) {
			urlStream = new URLStream();
			urlStream.endian = Endian.LITTLE_ENDIAN;
			addEventHandlers();
			filesList = [];
			filesDict = new Map<String, IZipFile>();
			parseFunc = parseSignature;
			urlStream.load(request);
		}
	}

	/**
	 * Loads a ZIP archive from a ByteArray.
	 *
	 * @param bytes The ByteArray containing the ZIP archive
	 */
	public function loadBytes(bytes:ByteArray):Void {
		if (urlStream == null && parseFunc == parseIdle) {
			filesList = [];
			filesDict = new Map<String, IZipFile>();
			bytes.position = 0;
			bytes.endian = Endian.LITTLE_ENDIAN;
			parseFunc = parseSignature;
			if (parse(bytes)) {
				parseFunc = parseIdle;
				dispatchEvent(new Event(Event.COMPLETE));
			} else {
				dispatchEvent(new ZipErrorEvent(ZipErrorEvent.PARSE_ERROR, "EOF"));
			}
		}
	}

	/**
	 * Immediately closes the stream and cancels the download operation.
	 * Files contained in the ZIP archive being loaded stay accessible
	 * through the getFileAt() and getFileByName() methods.
	 */
	public function close():Void {
		if (urlStream != null) {
			parseFunc = parseIdle;
			removeEventHandlers();
			urlStream.close();
			urlStream = null;
		}
	}

	/**
	 * Serializes this zip archive into an IDataOutput stream (such as
	 * ByteArray or FileStream) according to PKZIP APPNOTE.TXT
	 *
	 * @param stream The stream to serialize the zip file into.
	 * @param includeAdler32 To decompress compressed files, Zip needs Adler32
	 * 		checksums to be injected into the zipped files. Zip will do that
	 * 		automatically if includeAdler32 is set to true. Note that if the
	 * 		ZIP contains a lot of files, or big files, the calculation of the
	 * 		checksums may take a while.
	 */
	public function serialize(stream:IDataOutput, includeAdler32:Bool = false):Void {
		if (stream != null && filesList.length > 0) {
			var endian:String = stream.endian;
			var ba:ByteArray = new ByteArray();
			stream.endian = ba.endian = Endian.LITTLE_ENDIAN;
			var offset:Int = 0;
			var files:Int = 0;
			for (i in 0...filesList.length) {
				var file:ZipFile = try cast(filesList[i], ZipFile) catch (e:Dynamic) null;
				if (file != null) {
					// first serialize the central directory item{

					// into our temporary ByteArray
					file.serialize(ba, includeAdler32, true, offset);
					// then serialize the file itself into the stream
					// and update the offset
					offset += file.serialize(stream, includeAdler32);
					// keep track of how many files we have written
					files++;
				}
			}
			if (ba.length > 0) {
				// Write the central directory items{

				stream.writeBytes(ba);
			}
			// Write end of central directory:
			// Write signature
			stream.writeUnsignedInt(SIG_END_OF_CENTRAL_DIRECTORY);
			// Write number of this disk (always 0)
			stream.writeShort(0);
			// Write number of this disk with the start of the central directory (always 0)
			stream.writeShort(0);
			// Write total number of entries on this disk
			stream.writeShort(files);
			// Write total number of entries
			stream.writeShort(files);
			// Write size
			stream.writeUnsignedInt(ba.length);
			// Write offset of start of central directory with respect to the starting disk number
			stream.writeUnsignedInt(offset);
			// Write zip file comment length (always 0)
			stream.writeShort(0);
			// Reset endian of stream
			stream.endian = endian;
		}
	}

	/**
	 * Gets the number of accessible files in the ZIP archive.
	 *
	 * @return The number of files
	 */
	public function getFileCount():Int {
		return (filesList != null) ? filesList.length : 0;
	}

	/**
	 * Retrieves a file contained in the ZIP archive, by index.
	 *
	 * @param index The index of the file to retrieve
	 * @return A reference to a ZipFile object
	 */
	public function getFileAt(index:Int):IZipFile {
		return (filesList != null) ? try
			cast(filesList[index], IZipFile)
		catch (e:Dynamic)
			null : null;
	}

	/**
	 * Retrieves a file contained in the ZIP archive, by filename.
	 *
	 * @param name The filename of the file to retrieve
	 * @return A reference to a ZipFile object
	 */
	public function getFileByName(name:String):IZipFile {
		// return (Reflect.field(filesDict, name) != null) ? try cast(Reflect.field(filesDict, name), IZipFile) catch(e:Dynamic) null : null;
		return filesDict[name] != null ? cast(filesDict[name], IZipFile) : null;
	}

	/**
	 * Adds a file to the ZIP archive.
	 *
	 * @param name The filename
	 * @param content The ByteArray containing the uncompressed data (pass <code>null</code> to add a folder)
	 * @param doCompress Compress the data after adding.
	 *
	 * @return A reference to the newly created ZipFile object
	 */
	public function addFile(name:String, content:ByteArray = null, doCompress:Bool = true):ZipFile {
		return addFileAt((filesList != null) ? filesList.length : 0, name, content, doCompress);
	}

	/**
	 * Adds a file from a String to the ZIP archive.
	 *
	 * @param name The filename
	 * @param content The String
	 * @param charset The character set
	 * @param doCompress Compress the string after adding.
	 *
	 * @return A reference to the newly created ZipFile object
	 */
	public function addFileFromString(name:String, content:String, charset:String = "utf-8", doCompress:Bool = true):ZipFile {
		return addFileFromStringAt((filesList != null) ? filesList.length : 0, name, content, charset, doCompress);
	}

	/**
	 * Adds a file to the ZIP archive, at a specified index.
	 *
	 * @param index The index
	 * @param name The filename
	 * @param content The ByteArray containing the uncompressed data (pass <code>null</code> to add a folder)
	 * @param doCompress Compress the data after adding.
	 *
	 * @return A reference to the newly created ZipFile object
	 */
	public function addFileAt(index:Int, name:String, content:ByteArray = null, doCompress:Bool = true):ZipFile {
		if (filesList == null) {
			filesList = [];
		}
		if (filesDict == null) {
			filesDict = new Map<String, IZipFile>();
		}
		// else if (Reflect.field(filesDict, name) != null)
		else if (filesDict[name] != null) {
			throw(new Error("File already exists: " + name + ". Please remove first."));
		}
		var file:ZipFile = new ZipFile();
		file.filename = name;
		file.setContent(content, doCompress);
		if (index >= filesList.length) {
			filesList.push(file);
		} else {
			// as3hx.Compat.arraySplice(filesList, index, 0, [file]);
			filesList.insert(index, file);
		}
		// Reflect.setField(filesDict, name, file);
		filesDict[name] = file;
		return file;
	}

	/**
	 * Adds a file from a String to the ZIP archive, at a specified index.
	 *
	 * @param index The index
	 * @param name The filename
	 * @param content The String
	 * @param charset The character set
	 * @param doCompress Compress the string after adding.
	 *
	 * @return A reference to the newly created ZipFile object
	 */
	public function addFileFromStringAt(index:Int, name:String, content:String, charset:String = "utf-8", doCompress:Bool = true):ZipFile {
		if (filesList == null) {
			filesList = [];
		}
		if (filesDict == null) {
			filesDict = new Map<String, IZipFile>();
		} else if (Reflect.field(filesDict, name) != null) {
			throw(new Error("File already exists: " + name + ". Please remove first."));
		}
		var file:ZipFile = new ZipFile();
		file.filename = name;
		file.setContentAsString(content, charset, doCompress);
		if (index >= filesList.length) {
			filesList.push(file);
		} else {
			// as3hx.Compat.arraySplice(filesList, index, 0, [file]);
			filesList.insert(index, file);
		}
		Reflect.setField(filesDict, name, file);
		return file;
	}

	/**
	 * Removes a file at a specified index from the ZIP archive.
	 *
	 * @param index The index
	 * @return A reference to the removed ZipFile object
	 */
	public function removeFileAt(index:Int):IZipFile {
		if (filesList != null && filesDict != null && index < filesList.length) {
			var file:IZipFile = try cast(filesList[index], IZipFile) catch (e:Dynamic) null;
			if (file != null) {
				filesList.splice(index, 1);
				// This is an intentional compilation error. See the README for handling the delete keyword
				// delete filesDict[file.filename];
				filesDict.remove(file.filename);
				return file;
			}
		}
		return null;
	}

	/**
	 * @private
	 */
	private function parse(stream:IDataInput):Bool {
		while (parseFunc(stream)) {}
		return (parseFunc == parseIdle);
	}

	/**
	 * @private
	 */
	private function parseIdle(stream:IDataInput):Bool {
		return false;
	}

	/**
	 * @private
	 */
	private function parseSignature(stream:IDataInput):Bool {
		if (stream.bytesAvailable >= 4) {
			var sig:Int = stream.readUnsignedInt();
			switch (sig) {
				case SIG_LOCAL_FILE_HEADER:
					parseFunc = parseLocalfile;
					currentFile = new ZipFile(charEncoding);
				case SIG_CENTRAL_FILE_HEADER, SIG_END_OF_CENTRAL_DIRECTORY, SIG_SPANNING_MARKER, SIG_DIGITAL_SIGNATURE, SIG_ZIP64_END_OF_CENTRAL_DIRECTORY,
					SIG_ZIP64_END_OF_CENTRAL_DIRECTORY_LOCATOR, SIG_DATA_DESCRIPTOR, SIG_ARCHIVE_EXTRA_DATA, SIG_SPANNING:
					parseFunc = parseIdle;
				default:
					throw(new Error("Unknown record signature: 0x" + Std.string(sig)));
			}
			return true;
		}
		return false;
	}

	/**
	 * @private
	 */
	private function parseLocalfile(stream:IDataInput):Bool {
		if (currentFile.parse(stream)) {
			if (currentFile.hasDataDescriptor) {
				// This file uses a data descriptor:{

				// "[A data] descriptor exists only if bit 3 of the
				// general purpose bit flag is set.  It is byte aligned
				// and immediately follows the last byte of compressed data.
				// This descriptor is used only when it was not possible to
				// seek in the output .ZIP file, e.g., when the output .ZIP file
				// was standard output or a non-seekable device" (APPNOTE.TXT).

				// The file parser stops parsing after the file header.
				// We need to figure out the compressed size of the file's
				// payload (by searching ahead for the data descriptor
				// signature). See findDataDescriptor() below.

				parseFunc = findDataDescriptor;
				ddBuffer = new ByteArray();
				ddSignature = 0;
				ddCompressedSize = 0;
				return true;
			}
			// No data descriptor: We're done.
			else {
				// Register file and dispatch FILE_LOADED event
				onFileLoaded();
				// TODO [CW] why do we check for parseIdle here?
				if (parseFunc != parseIdle) {
					parseFunc = parseSignature;
					return true;
				}
			}
		}
		return false;
	}

	/**
	 * @private
	 */
	private function findDataDescriptor(stream:IDataInput):Bool {
		while (stream.bytesAvailable > 0) {
			var c:Int = stream.readUnsignedByte();
			ddSignature = (ddSignature >>> 8) | (c << 24);
			if (ddSignature == SIG_DATA_DESCRIPTOR) {
				// Data descriptor signature found{

				// Remove last three (signature-) bytes from buffer
				ddBuffer.length -= 3;
				parseFunc = validateDataDescriptor;
				return true;
			}
			ddBuffer.writeByte(c);
		}
		return false;
	}

	/**
	 * @private
	 */
	private function validateDataDescriptor(stream:IDataInput):Bool // TODO [CW]
	{
		// In case validation fails, we should reexamine the
		// alleged sig/crc32/size bytes (minus the first byte)
		if (stream.bytesAvailable >= 12) {
			// Get data from descriptor{

			var ddCRC32:Int = stream.readUnsignedInt();
			var ddSizeCompressed:Int = stream.readUnsignedInt();
			var ddSizeUncompressed:Int = stream.readUnsignedInt();
			// If the compressed size from the descriptor matches the buffer length,
			// we can be reasonably sure that this really is the descriptor.
			if (ddBuffer.length == ddSizeCompressed) {
				ddBuffer.position = 0;
				// Inject the descriptor data into current file
				currentFile._crc32 = ddCRC32;
				currentFile._sizeCompressed = ddSizeCompressed;
				currentFile._sizeUncompressed = ddSizeUncompressed;
				// Copy buffer into current file
				currentFile.parseContent(ddBuffer);
				// Register file and dispatch FILE_LOADED event
				onFileLoaded();
				// Continue with next file
				parseFunc = parseSignature;
			}
			// TODO [CW] check endianness (i think it's big endian, gotta set that on buffer)
			else {
				ddBuffer.writeUnsignedInt(ddCRC32);
				ddBuffer.writeUnsignedInt(ddSizeCompressed);
				ddBuffer.writeUnsignedInt(ddSizeUncompressed);
				parseFunc = findDataDescriptor;
			}
			return true;
		}
		return false;
	}

	/**
	 * @private
	 */
	private function onFileLoaded():Void {
		filesList.push(currentFile);
		if (currentFile.filename != null) {
			filesDict[currentFile.filename] = currentFile;
		}
		dispatchEvent(new ZipEvent(ZipEvent.FILE_LOADED, currentFile));
		currentFile = null;
	}

	/**
	 * @private
	 */
	private function progressHandler(evt:Event):Void {
		dispatchEvent(evt.clone());
		try {
			if (parse(urlStream)) {
				close();
				dispatchEvent(new Event(Event.COMPLETE));
			}
		} catch (e:Error) {
			close();
			if (hasEventListener(ZipErrorEvent.PARSE_ERROR)) {
				dispatchEvent(new ZipErrorEvent(ZipErrorEvent.PARSE_ERROR, e.message));
			} else {
				throw(e);
			}
		}
	}

	/**
	 * @private
	 */
	private function defaultHandler(evt:Event):Void {
		dispatchEvent(evt.clone());
	}

	/**
	 * @private
	 */
	private function defaultErrorHandler(evt:Event):Void {
		close();
		dispatchEvent(evt.clone());
	}

	/**
	 * @private
	 */
	private function addEventHandlers():Void {
		urlStream.addEventListener(Event.COMPLETE, defaultHandler);
		urlStream.addEventListener(Event.OPEN, defaultHandler);
		urlStream.addEventListener(HTTPStatusEvent.HTTP_STATUS, defaultHandler);
		urlStream.addEventListener(IOErrorEvent.IO_ERROR, defaultErrorHandler);
		urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, defaultErrorHandler);
		urlStream.addEventListener(ProgressEvent.PROGRESS, progressHandler);
	}

	/**
	 * @private
	 */
	private function removeEventHandlers():Void {
		urlStream.removeEventListener(Event.COMPLETE, defaultHandler);
		urlStream.removeEventListener(Event.OPEN, defaultHandler);
		urlStream.removeEventListener(HTTPStatusEvent.HTTP_STATUS, defaultHandler);
		urlStream.removeEventListener(IOErrorEvent.IO_ERROR, defaultErrorHandler);
		urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, defaultErrorHandler);
		urlStream.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
	}
}
