package;

import haxe.io.Bytes;
import haxe.io.Path;
import lime.utils.AssetBundle;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets;

#if sys
import sys.FileSystem;
#end

#if disable_preloader_assets
@:dox(hide) class ManifestResources {
	public static var preloadLibraries:Array<Dynamic>;
	public static var preloadLibraryNames:Array<String>;
	public static var rootPath:String;

	public static function init (config:Dynamic):Void {
		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();
	}
}
#else
@:access(lime.utils.Assets)


@:keep @:dox(hide) class ManifestResources {


	public static var preloadLibraries:Array<AssetLibrary>;
	public static var preloadLibraryNames:Array<String>;
	public static var rootPath:String;


	public static function init (config:Dynamic):Void {

		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();

		rootPath = null;

		if (config != null && Reflect.hasField (config, "rootPath")) {

			rootPath = Reflect.field (config, "rootPath");

			if(!StringTools.endsWith (rootPath, "/")) {

				rootPath += "/";

			}

		}

		if (rootPath == null) {

			#if (ios || tvos || webassembly)
			rootPath = "assets/";
			#elseif android
			rootPath = "";
			#elseif (console || sys)
			rootPath = lime.system.System.applicationDirectory;
			#else
			rootPath = "./";
			#end

		}

		#if (openfl && !flash && !display)
		
		#end

		var data, manifest, library, bundle;

		data = '{"name":null,"assets":"aoy4:pathy25:assets%2FbigExplosion.sdey4:sizei179264y4:typey6:BINARYy2:idR1y7:preloadtgoR0y24:assets%2FblazingFire.sdeR2i58308R3R4R5R7R6tgoR0y30:assets%2FcoinShower_simple.sdeR2i17070R3R4R5R8R6tgoR0y19:assets%2FdryIce.sdeR2i217385R3R4R5R9R6tgoR0y23:assets%2FexampleSim.sdeR2i1724R3R4R5R10R6tgoR0y22:assets%2Ffireworks.sdeR2i8171R3R4R5R11R6tgoR0y25:assets%2FglitterBurst.sdeR2i4178R3R4R5R12R6tgoR0y26:assets%2FgravityFields.sdeR2i1782R3R4R5R13R6tgoR0y19:assets%2Frocket.sdeR2i65429R3R4R5R14R6tgoR0y21:assets%2Fsnowfall.sdeR2i1825R3R4R5R15R6tgh","rootPath":null,"version":2,"libraryArgs":[],"libraryType":null}';
		manifest = AssetManifest.parse (data, rootPath);
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("default", library);
		

		library = Assets.getLibrary ("default");
		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("default");
		

	}


}

#if !display
#if flash

@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_bigexplosion_sde extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_blazingfire_sde extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_coinshower_simple_sde extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_dryice_sde extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_examplesim_sde extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_fireworks_sde extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_glitterburst_sde extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_gravityfields_sde extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_rocket_sde extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_snowfall_sde extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__manifest_default_json extends null { }


#elseif (desktop || cpp)

@:keep @:file("Assets/bigExplosion.sde") @:noCompletion #if display private #end class __ASSET__assets_bigexplosion_sde extends haxe.io.Bytes {}
@:keep @:file("Assets/blazingFire.sde") @:noCompletion #if display private #end class __ASSET__assets_blazingfire_sde extends haxe.io.Bytes {}
@:keep @:file("Assets/coinShower_simple.sde") @:noCompletion #if display private #end class __ASSET__assets_coinshower_simple_sde extends haxe.io.Bytes {}
@:keep @:file("Assets/dryIce.sde") @:noCompletion #if display private #end class __ASSET__assets_dryice_sde extends haxe.io.Bytes {}
@:keep @:file("Assets/exampleSim.sde") @:noCompletion #if display private #end class __ASSET__assets_examplesim_sde extends haxe.io.Bytes {}
@:keep @:file("Assets/fireworks.sde") @:noCompletion #if display private #end class __ASSET__assets_fireworks_sde extends haxe.io.Bytes {}
@:keep @:file("Assets/glitterBurst.sde") @:noCompletion #if display private #end class __ASSET__assets_glitterburst_sde extends haxe.io.Bytes {}
@:keep @:file("Assets/gravityFields.sde") @:noCompletion #if display private #end class __ASSET__assets_gravityfields_sde extends haxe.io.Bytes {}
@:keep @:file("Assets/rocket.sde") @:noCompletion #if display private #end class __ASSET__assets_rocket_sde extends haxe.io.Bytes {}
@:keep @:file("Assets/snowfall.sde") @:noCompletion #if display private #end class __ASSET__assets_snowfall_sde extends haxe.io.Bytes {}
@:keep @:file("") @:noCompletion #if display private #end class __ASSET__manifest_default_json extends haxe.io.Bytes {}



#else



#end

#if (openfl && !flash)

#if html5

#else

#end

#end
#end

#end