package com.funkypandagame.stardustplayer;

class SDEConstants {
	private static inline var EMITTER_NAME_PREFIX:String = "stardustEmitter_";
	public static inline var ATLAS_IMAGE_NAME:String = "atlas_0.png";
	public static inline var ATLAS_XML_NAME:String = "atlas_0.xml";

	public static function getXMLName(id:String):String {
		return EMITTER_NAME_PREFIX + id + ".xml";
	}

	public static function getParticleSnapshotName(id:String):String {
		return "emitterSnapshot_" + id + ".bytearray";
	}

	public static function isEmitterXMLName(filename:String):Bool {
		return (filename.substr(0, 16) == EMITTER_NAME_PREFIX);
	}

	public static function getEmitterID(XMLFilename:String):String {
		return XMLFilename.substr(16).split(".")[0];
	}

	// Returns the prefix for all textures used by emitterId in the atlas.
	public static function getSubTexturePrefix(emitterId:String):String {
		return "emitter_" + emitterId + "_image_";
	}

	// Returns names for subTextures .sde files.
	public static function getSubTextureName(emitterId:String, imageNumber:Int, numberOfImagesInAtlas:Int):String {
		return getSubTexturePrefix(emitterId) + intToSortableStr(imageNumber, numberOfImagesInAtlas);
	}

	/**
	 *   Convert an integer to a string that can be sorted with Array.CASEINSENSITIVE
	 *   @param val Integer to convert
	 *   @param maxValue Maximum value of integers that will be sorted
	 *   @return The sortable string
	 *   @author Jackson Dunstan, JacksonDunstan.com
	 */
	private static function intToSortableStr(val:Int, maxValue:Int):String {
		// Get the number of digits in the string and the value of the most-significant digit
		var digitValue:Int = 1;
		var digits:Int = 0;
		var tempMaxValue = maxValue;
		while (tempMaxValue >= 10) {
			digits++;
			digitValue *= 10;
			tempMaxValue = Std.int(tempMaxValue / 10);
		}
		digitValue = Std.int(digitValue / 10);

		// Build the string from most-significant to least-significant digit
		var ret = "";
		var tempVal = val;
		for (i in 0...digits) {
			var digit = Std.int(tempVal / digitValue);
			ret += digit;
			tempVal -= digit * digitValue;
			digitValue = Std.int(digitValue / 10);
		}
		return ret;
	}

	public function new() {}
}
