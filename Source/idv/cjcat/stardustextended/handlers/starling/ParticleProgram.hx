package idv.cjcat.stardustextended.handlers.starling;

import openfl.display3D.Context3DTextureFormat;
import starling.core.Starling;
import starling.rendering.Program;
import starling.textures.TextureSmoothing;
import starling.utils.RenderUtil;

class ParticleProgram {
	private static var sProgramNameCache:Map<UInt, String> = new Map<UInt, String>();

	public static function getProgram(texMipmap:Bool = true, texFormat:String = "bgra", texSmoothing:String = "bilinear"):Program {
		var target:Starling = Starling.current;
		var programName:String = getImageProgramName(texMipmap, texFormat, texSmoothing);

		var program:Program = target.painter.getProgram(programName);
		if (program == null) {
			// this is the input data we'll pass to the shaders:{

			//
			// va0 -> position
			// va1 -> color
			// va2 -> texCoords
			// vc0 -> alpha
			// vc1 -> mvpMatrix
			// fs0 -> texture
			var vertexShader:String = "m44 op, va0, vc1 \n" + // 4x4 matrix transform to output clipspace
				"mul v0, va1, vc0 \n" + // multiply alpha (vc0) with color (va1)
				"mov v1, va2      \n"; // pass texture coordinates to fragment program

			var fragmentShader:String = "tex ft1,  v1, fs0 <???> \n" + // sample texture 0
				"mul  oc, ft1,  v0       \n"; // multiply color with texel color

			fragmentShader = StringTools.replace(fragmentShader, "<???>", RenderUtil.getTextureLookupFlags(texFormat, texMipmap, false, texSmoothing));
			program = Program.fromSource(vertexShader, fragmentShader);
			target.painter.registerProgram(programName, program);
		}
		return program;
	}

	private static function getImageProgramName(mipMap:Bool, format:String, smoothing:String):String {
		var bitField:UInt = 0;

		if (mipMap) {
			bitField = bitField | Std.int(1 << 1);
		}

		if (smoothing == TextureSmoothing.NONE) {
			bitField = bitField | (1 << 3);
		} else if (smoothing == TextureSmoothing.TRILINEAR) {
			bitField = bitField | (1 << 4);
		}

		if (format == Context3DTextureFormat.COMPRESSED) {
			bitField = bitField | (1 << 5);
		} else if (format == "compressedAlpha") {
			bitField = bitField | (1 << 6);
		}

		var name:String = sProgramNameCache[bitField];

		if (name == null) {
			name = "__STARDUST_RENDERER." + Std.string(bitField);
			sProgramNameCache[bitField] = name;
		}
		return name;
	}

	public function new() {}
}
