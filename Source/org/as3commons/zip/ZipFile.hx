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

import openfl.errors.Error;
import openfl.utils.IDataOutput;
import openfl.utils.Endian;
import openfl.utils.Function;
import openfl.utils.IDataInput;
import openfl.utils.ByteArray;
import org.as3commons.zip.utils.ChecksumUtil;

/**
 * Represents a file contained in a ZIP archive.
 *
 * @author Claus Wahlers
 * @author Max Herkender
 */
class ZipFile implements IZipFile {
	public var date(get, set):Date;
	public var filename(get, set):String;

	private var _hasDataDescriptor:Bool = false;

	public var hasDataDescriptor(get, never):Bool;

	public var content(get, set):ByteArray;
	public var versionNumber(get, never):String;
	public var sizeCompressed(get, never):Int;
	public var sizeUncompressed(get, never):Int;

	private var _versionHost:Int = 0;
	private var _versionNumber:String = "2.0";
	private var _compressionMethod:Int = 8;
	private var _encrypted:Bool = false;
	private var _implodeDictSize:Int = -1;
	private var _implodeShannonFanoTrees:Int = -1;
	private var _deflateSpeedOption:Int = -1;

	private var _hasCompressedPatchedData:Bool = false;
	private var _date:Date;
	private var _adler32:Int;
	private var _hasAdler32:Bool = false;
	private var _sizeFilename:Int = 0;
	private var _sizeExtra:Int = 0;
	private var _filename:String = "";
	private var _filenameEncoding:String;
	private var _extraFields:Map<UInt, ByteArray>;
	private var _comment:String = "";
	private var _content:ByteArray;

	public var _crc32:Int;
	public var _sizeCompressed:Int = 0;
	public var _sizeUncompressed:Int = 0;

	private var isCompressed:Bool = false;
	private var parseFunc:Function;

	// compression methods

	/**
	 * @private
	 */
	public static inline var COMPRESSION_NONE:Int = 0;

	/**
	 * @private
	 */
	public static inline var COMPRESSION_SHRUNK:Int = 1;

	/**
	 * @private
	 */
	public static inline var COMPRESSION_REDUCED_1:Int = 2;

	/**
	 * @private
	 */
	public static inline var COMPRESSION_REDUCED_2:Int = 3;

	/**
	 * @private
	 */
	public static inline var COMPRESSION_REDUCED_3:Int = 4;

	/**
	 * @private
	 */
	public static inline var COMPRESSION_REDUCED_4:Int = 5;

	/**
	 * @private
	 */
	public static inline var COMPRESSION_IMPLODED:Int = 6;

	/**
	 * @private
	 */
	public static inline var COMPRESSION_TOKENIZED:Int = 7;

	/**
	 * @private
	 */
	public static inline var COMPRESSION_DEFLATED:Int = 8;

	/**
	 * @private
	 */
	public static inline var COMPRESSION_DEFLATED_EXT:Int = 9;

	/**
	 * @private
	 */
	public static inline var COMPRESSION_IMPLODED_PKWARE:Int = 10;

	/**
	 * @private
	 */
	// private static var HAS_UNCOMPRESS:Bool = true;

	/**
	 * @private
	 */
	private static var HAS_INFLATE:Bool = true;

	/**
	 * Constructor
	 */
	public function new(filenameEncoding:String = "utf-8") {
		parseFunc = parseFileHead;
		_filenameEncoding = filenameEncoding;
		_extraFields = new Map<UInt, ByteArray>();
		_content = new ByteArray();
		_content.endian = Endian.BIG_ENDIAN;
	}

	/**
	 * The Date and time the file was created.
	 */
	private function get_date():Date {
		return _date;
	}

	private function set_date(value:Date):Date {
		_date = ((value != null)) ? value : Date.now();
		return value;
	}

	/**
	 * The file name (including relative path).
	 */
	private function get_filename():String {
		return _filename;
	}

	private function set_filename(value:String):String {
		_filename = value;
		return value;
	}

	/**
	 * Whether this file has a data descriptor or not (only used internally).
	 */
	private function get_hasDataDescriptor():Bool {
		return _hasDataDescriptor;
	}

	/**
	 * The raw, uncompressed file.
	 */
	private function get_content():ByteArray {
		if (isCompressed) {
			uncompress();
		}
		return _content;
	}

	private function set_content(data:ByteArray):ByteArray {
		setContent(data);
		return data;
	}

	/**
	 * Sets the file's content as ByteArray.
	 *
	 * @param data The new content.
	 * @param doCompress Compress the data after adding.
	 */
	public function setContent(data:ByteArray, doCompress:Bool = true):Void {
		if (data != null && data.length > 0) {
			data.position = 0;
			data.readBytes(_content, 0, data.length);
			_crc32 = ChecksumUtil.CRC32(_content);
			_hasAdler32 = false;
		} else {
			_content.length = 0;
			_content.position = 0;
			isCompressed = false;
		}
		if (doCompress) {
			compress();
		} else {
			_sizeUncompressed = _sizeCompressed = _content.length;
		}
	}

	/**
	 * The ZIP specification version supported by the software
	 * used to encode the file.
	 */
	private function get_versionNumber():String {
		return _versionNumber;
	}

	/**
	 * The size of the compressed file (in bytes).
	 */
	private function get_sizeCompressed():Int {
		return _sizeCompressed;
	}

	/**
	 * The size of the uncompressed file (in bytes).
	 */
	private function get_sizeUncompressed():Int {
		return _sizeUncompressed;
	}

	/**
	 * Gets the files content as string.
	 *
	 * @param recompress If <code>true</code>, the raw file content
	 * is recompressed after decoding the string.
	 *
	 * @param charset The character set used for decoding.
	 *
	 * @return The file as string.
	 */
	public function getContentAsString(recompress:Bool = true, charset:String = "utf-8"):String {
		if (isCompressed) {
			uncompress();
		}
		_content.position = 0;
		var str:String;
		// Is readMultiByte completely trustworthy with utf-8?
		// For now, readUTFBytes will take over.
		if (charset == "utf-8") {
			str = _content.readUTFBytes(_content.bytesAvailable);
		} else {
			str = _content.readMultiByte(_content.bytesAvailable, charset);
		}
		_content.position = 0;
		if (recompress) {
			compress();
		}
		return str;
	}

	/**
	 * Sets a string as the file's content.
	 *
	 * @param value The string.
	 * @param charset The character set used for decoding.
	 * @param doCompress Compress the string after adding.
	 */
	public function setContentAsString(value:String, charset:String = "utf-8", doCompress:Bool = true):Void {
		_content.length = 0;
		_content.position = 0;
		isCompressed = false;
		if (value != null && value.length > 0) {
			if (charset == "utf-8") {
				_content.writeUTFBytes(value);
			} else {
				_content.writeMultiByte(value, charset);
			}
			_crc32 = ChecksumUtil.CRC32(_content);
			_hasAdler32 = false;
		}
		if (doCompress) {
			compress();
		} else {
			_sizeUncompressed = _sizeCompressed = _content.length;
		}
	}

	/**
	 * Serializes this zip archive into an IDataOutput stream (such as
	 * ByteArray or FileStream) according to PKZIP APPNOTE.TXT
	 *
	 * @param stream The stream to serialize the zip archive into.
	 * @param includeAdler32 If set to true, include Adler32 checksum.
	 * @param centralDir If set to true, serialize a central directory entry
	 * @param centralDirOffset Relative offset of local header (for central directory only).
	 *
	 * @return The number of bytes written to the stream.
	 */
	public function serialize(stream:IDataOutput, includeAdler32:Bool, centralDir:Bool = false, centralDirOffset:Int = 0):Int {
		if (stream == null) {
			return 0;
		}
		if (centralDir) {
			// Write central directory file header signature{

			stream.writeUnsignedInt(Zip.SIG_CENTRAL_FILE_HEADER);
			// Write "version made by" host (usually 0) and number (always 2.0)
			stream.writeShort((_versionHost << 8) | 0x14);
		}
		// Write local file header signature
		else {
			stream.writeUnsignedInt(Zip.SIG_LOCAL_FILE_HEADER);
		}
		// Write "version needed to extract" host (usually 0) and number (always 2.0)
		stream.writeShort((_versionHost << 8) | 0x14);
		// Write the general purpose flag
		// - no encryption
		// - normal deflate
		// - no data descriptors
		// - no compressed patched data
		// - unicode as specified in _filenameEncoding
		stream.writeShort(((_filenameEncoding == "utf-8")) ? 0x0800 : 0);
		// Write compression method (always deflate)
		stream.writeShort((isCompressed) ? COMPRESSION_DEFLATED : COMPRESSION_NONE);
		// Write date
		var d:Date = ((_date != null)) ? _date : Date.now();
		var msdosTime:Int = ((d.getSeconds()) | ((d.getMinutes()) << 5)) | ((d.getHours()) << 11);
		var msdosDate:Int = ((d.getDate()) | ((d.getMonth() + 1) << 5)) | ((d.getFullYear() - 1980) << 9);
		stream.writeShort(msdosTime);
		stream.writeShort(msdosDate);
		// Write CRC32
		stream.writeUnsignedInt(_crc32);
		// Write compressed size
		stream.writeUnsignedInt(_sizeCompressed);
		// Write uncompressed size
		stream.writeUnsignedInt(_sizeUncompressed);
		// Prep filename
		var ba:ByteArray = new ByteArray();
		ba.endian = Endian.LITTLE_ENDIAN;
		if (_filenameEncoding == "utf-8") {
			ba.writeUTFBytes(_filename);
		} else {
			ba.writeMultiByte(_filename, _filenameEncoding);
		}
		var filenameSize:Int = ba.position;
		// Prep extra fields
		for (headerId in _extraFields.keys()) {
			var extraBytes:ByteArray = _extraFields[headerId];
			if (extraBytes != null) {
				ba.writeShort((headerId));
				ba.writeShort((extraBytes.length));
				ba.writeBytes(extraBytes);
			}
		}
		if (includeAdler32) {
			if (!_hasAdler32) {
				var compressed:Bool = isCompressed;
				if (compressed) {
					uncompress();
				}
				_adler32 = ChecksumUtil.Adler32(_content, 0, _content.length);
				_hasAdler32 = true;
				if (compressed) {
					compress();
				}
			}
			ba.writeShort(0xdada);
			ba.writeShort(4);
			ba.writeUnsignedInt(_adler32);
		}
		var extrafieldsSize:Int = (ba.position - filenameSize);
		// Prep comment (currently unused)
		if (centralDir && _comment.length > 0) {
			if (_filenameEncoding == "utf-8") {
				ba.writeUTFBytes(_comment);
			} else {
				ba.writeMultiByte(_comment, _filenameEncoding);
			}
		}
		var commentSize:Int = (ba.position - filenameSize - extrafieldsSize);
		// Write filename and extra field sizes
		stream.writeShort(filenameSize);
		stream.writeShort(extrafieldsSize);
		if (centralDir) {
			// Write comment size{

			stream.writeShort(commentSize);
			// Write disk number start (always 0)
			stream.writeShort(0);
			// Write file attributes (always 0)
			stream.writeShort(0);
			stream.writeUnsignedInt(0);
			// Write relative offset of local header
			stream.writeUnsignedInt(centralDirOffset);
		}

		// Write filename, extra field and comment
		if (filenameSize + extrafieldsSize + commentSize > 0) {
			stream.writeBytes(ba);
		}
		// Write file
		var fileSize:Int = 0;
		if (!centralDir && _content.length > 0) {
			if (isCompressed) {
				// if (HAS_UNCOMPRESS || HAS_INFLATE) {
				if (HAS_INFLATE) {
					fileSize = _content.length;
					stream.writeBytes(_content, 0, fileSize);
				} else {
					fileSize = (_content.length - 6);
					stream.writeBytes(_content, 2, fileSize);
				}
			} else {
				fileSize = _content.length;
				stream.writeBytes(_content, 0, fileSize);
			}
		}
		var size:Int = (30 + filenameSize + extrafieldsSize + commentSize + fileSize);
		if (centralDir) {
			size += 16;
		}
		return size;
	}

	/**
	 * @private
	 */
	public function parse(stream:IDataInput):Bool {
		while (stream.bytesAvailable != null && parseFunc(stream)) {}
		return (parseFunc == parseFileIdle);
	}

	/**
	 * @private
	 */
	private function parseFileIdle(stream:IDataInput):Bool {
		return false;
	}

	/**
	 * @private
	 */
	private function parseFileHead(stream:IDataInput):Bool {
		if (stream.bytesAvailable >= 30) {
			parseHead(stream);
			if (_sizeFilename + _sizeExtra > 0) {
				parseFunc = parseFileHeadExt;
			} else {
				parseFunc = parseFileContent;
			}
			return true;
		}
		return false;
	}

	/**
	 * @private
	 */
	private function parseFileHeadExt(stream:IDataInput):Bool {
		if (stream.bytesAvailable >= _sizeFilename + _sizeExtra) {
			parseHeadExt(stream);
			parseFunc = parseFileContent;
			return true;
		}
		return false;
	}

	/**
	 * @private
	 */
	private function parseFileContent(stream:IDataInput):Bool {
		var continueParsing:Bool = true;
		if (_hasDataDescriptor) {
			// If the file has a data descriptor, bail out.{

			// We first need to figure out the length of the file.
			// See Zip::parseLocalfile()
			parseFunc = parseFileIdle;
			continueParsing = false;
		} else if (_sizeCompressed == 0) {
			// This entry has no file attached{
			parseFunc = parseFileIdle;
		} else if (stream.bytesAvailable >= _sizeCompressed) {
			parseContent(stream);
			parseFunc = parseFileIdle;
		} else {
			continueParsing = false;
		}
		return continueParsing;
	}

	/**
	 * @private
	 */
	private function parseHead(data:IDataInput):Void {
		var vSrc:Int = data.readUnsignedShort();
		_versionHost = vSrc >> 8;
		_versionNumber = Math.floor((vSrc & 0xff) / 10) + "." + ((vSrc & 0xff) % 10);
		var flag:Int = data.readUnsignedShort();
		_compressionMethod = data.readUnsignedShort();
		_encrypted = (flag & 0x01) != 0;
		_hasDataDescriptor = (flag & 0x08) != 0;
		_hasCompressedPatchedData = (flag & 0x20) != 0;
		if ((flag & 800) != 0) {
			_filenameEncoding = "utf-8";
		}
		if (_compressionMethod == COMPRESSION_IMPLODED) {
			_implodeDictSize = ((flag & 0x02) != 0) ? 8192 : 4096;
			_implodeShannonFanoTrees = ((flag & 0x04) != 0) ? 3 : 2;
		} else if (_compressionMethod == COMPRESSION_DEFLATED) {
			_deflateSpeedOption = (flag & 0x06) >> 1;
		}
		var msdosTime:Int = data.readUnsignedShort();
		var msdosDate:Int = data.readUnsignedShort();
		var sec:Int = (msdosTime & 0x001f);
		var min:Int = (msdosTime & 0x07e0) >> 5;
		var hour:Int = (msdosTime & 0xf800) >> 11;
		var day:Int = (msdosDate & 0x001f);
		var month:Int = (msdosDate & 0x01e0) >> 5;
		var year:Int = (((msdosDate & 0xfe00) >> 9) + 1980);
		_date = new Date(year, month - 1, day, hour, min, sec);
		_crc32 = data.readUnsignedInt();
		_sizeCompressed = data.readUnsignedInt();
		_sizeUncompressed = data.readUnsignedInt();
		_sizeFilename = data.readUnsignedShort();
		_sizeExtra = data.readUnsignedShort();
	}

	/**
	 * @private
	 */
	private function parseHeadExt(data:IDataInput):Void {
		if (_filenameEncoding == "utf-8") {
			_filename = data.readUTFBytes(_sizeFilename);
		} else {
			_filename = data.readMultiByte(_sizeFilename, _filenameEncoding);
		}
		var bytesLeft:Int = _sizeExtra;
		while (bytesLeft > 4) {
			var headerId:UInt = data.readUnsignedShort();
			var dataSize:UInt = data.readUnsignedShort();
			if (dataSize > bytesLeft) {
				throw new Error("Parse error in file " + _filename + ": Extra field data size too big.");
			}
			if (headerId == 0xdada && dataSize == 4) {
				_adler32 = data.readUnsignedInt();
				_hasAdler32 = true;
			} else if (dataSize > 0) {
				var extraBytes:ByteArray = new ByteArray();
				data.readBytes(extraBytes, 0, dataSize);
				_extraFields[headerId] = extraBytes;
			}
			bytesLeft -= (dataSize + 4);
		}
		if (bytesLeft > 0) {
			data.readBytes(new ByteArray(), 0, bytesLeft);
		}
	}

	/**
	 * @private
	 */
	public function parseContent(data:IDataInput):Void {
		if (_compressionMethod == COMPRESSION_DEFLATED && !_encrypted) {
			// if (HAS_UNCOMPRESS || HAS_INFLATE) {
			if (HAS_INFLATE) {
				// Adobe Air supports inflate decompression.{

				// If we got here, this is an Air application
				// and we can decompress without using the Adler32 hack
				// so we just write out the raw deflate compressed file
				data.readBytes(_content, 0, _sizeCompressed);
			} else if (_hasAdler32) {
				// Add zlib header{

				// CMF (compression method and info)
				_content.writeByte(0x78);
				// FLG (compression level, preset dict, checkbits)
				var flg:Int = (~_deflateSpeedOption << 6) & 0xc0;
				flg += (31 - (((0x78 << 8) | flg) % 31));
				_content.writeByte(flg);
				// Add raw deflate-compressed file
				data.readBytes(_content, 2, _sizeCompressed);
				// Add adler32 checksum
				_content.position = _content.length;
				_content.writeUnsignedInt(_adler32);
			} else {
				throw new Error("Adler32 checksum not found.");
			}
			isCompressed = true;
		} else if (_compressionMethod == COMPRESSION_NONE) {
			data.readBytes(_content, 0, _sizeCompressed);
			isCompressed = false;
		} else {
			throw new Error("Compression method " + _compressionMethod + " is not supported.");
		}
		_content.position = 0;
	}

	/**
	 * @private
	 */
	private function compress():Void {
		if (!isCompressed) {
			if (_content.length > 0) {
				_content.position = 0;
				_sizeUncompressed = _content.length;
				if (HAS_INFLATE) {
					_content.deflate();
					_sizeCompressed = _content.length;
				}
				/* else if (HAS_UNCOMPRESS) {
					_content.compress.apply(_content, ["deflate"]);
					_sizeCompressed = _content.length;
				}*/
				else {
					_content.compress();
					_sizeCompressed = (_content.length - 6);
				}
				_content.position = 0;
				isCompressed = true;
			} else {
				_sizeCompressed = 0;
				_sizeUncompressed = 0;
			}
		}
	}

	/**
	 * @private
	 */
	private function uncompress():Void {
		if (isCompressed && _content.length > 0) {
			_content.position = 0;
			if (HAS_INFLATE) {
				_content.inflate();
			}
			/*  else if (HAS_UNCOMPRESS) {
				_content.uncompress.apply(_content, ["deflate"]);
			}*/
			else {
				_content.uncompress();
			}
			_content.position = 0;
			isCompressed = false;
		}
	}

	/**
	 * Returns a string representation of the ZipFile object.
	 */
	public function toString():String {
		return "[ZipFile]" + "\n  name:" + _filename + "\n  date:" + _date + "\n  sizeCompressed:" + _sizeCompressed + "\n  sizeUncompressed:"
			+ _sizeUncompressed + "\n  versionHost:" + _versionHost + "\n  versionNumber:" + _versionNumber + "\n  compressionMethod:" + _compressionMethod
			+ "\n  encrypted:" + _encrypted + "\n  hasDataDescriptor:" + _hasDataDescriptor + "\n  hasCompressedPatchedData:" + _hasCompressedPatchedData
			+ "\n  filenameEncoding:" + _filenameEncoding + "\n  crc32:" + Std.string(_crc32) + "\n  adler32:" + Std.string(_adler32);
	}
}
