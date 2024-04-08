package com.funkypandagame.stardustplayer;

import com.funkypandagame.stardustplayer.RawEmitterData;
import com.funkypandagame.stardustplayer.SDEConstants;
import com.funkypandagame.stardustplayer.ISimLoader;
import openfl.Vector;
import org.as3commons.zip.IZipFile;
import haxe.Json;
import openfl.errors.Error;
import org.as3commons.zip.Zip;
import com.funkypandagame.stardustplayer.emitter.EmitterBuilder;
import com.funkypandagame.stardustplayer.emitter.EmitterValueObject;
import com.funkypandagame.stardustplayer.project.ProjectValueObject;
import com.funkypandagame.stardustplayer.sequenceLoader.ISequenceLoader;
import com.funkypandagame.stardustplayer.sequenceLoader.LoadByteArrayJob;
import com.funkypandagame.stardustplayer.sequenceLoader.SequenceLoader;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.utils.ByteArray;
import idv.cjcat.stardustextended.Stardust;
import idv.cjcat.stardustextended.actions.Action;
import idv.cjcat.stardustextended.actions.Spawn;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.handlers.starling.StarlingHandler;
import starling.textures.SubTexture;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class SimLoader extends EventDispatcher implements ISimLoader {
	public static inline var DESCRIPTOR_FILENAME:String = "descriptor.json";
	public static inline var BACKGROUND_FILENAME:String = "background.png";

	private var sequenceLoader:ISequenceLoader = new SequenceLoader();
	private var projectLoaded:Bool = false;
	private var loadedZip:Zip;
	private var descriptorJSON:Dynamic;
	private var rawEmitterDatas:Vector<RawEmitterData> = new Vector<RawEmitterData>();
	private var atlas:TextureAtlas;

	/** Loads an .sde file (that is in a byteArray). */
	public function loadSim(data:ByteArray):Void {
		projectLoaded = false;
		sequenceLoader.clearAllJobs();

		loadedZip = new Zip();
		loadedZip.loadBytes(data);
		descriptorJSON = Json.parse(loadedZip.getFileByName(DESCRIPTOR_FILENAME).getContentAsString());
		if (descriptorJSON == null) {
			throw new Error('$DESCRIPTOR_FILENAME not found.');
		}
		if (Std.parseFloat(descriptorJSON.version) < Stardust.VERSION) {
			trace(' Stardust Sim Loader:WARNING loaded simulation is created with an old version of the editor, it might not run.');
		}
		var atlasFound:Bool = false;
		for (i in 0...loadedZip.getFileCount()) {
			var loadedFileName:String = loadedZip.getFileAt(i).filename;
			if (loadedFileName == SDEConstants.ATLAS_IMAGE_NAME) {
				var loadAtlasJob:LoadByteArrayJob = new LoadByteArrayJob(loadedFileName, loadedFileName, loadedZip.getFileAt(i).content);
				sequenceLoader.addJob(loadAtlasJob);
				sequenceLoader.addEventListener(Event.COMPLETE, onProjectAtlasLoaded);
				sequenceLoader.loadSequence();
				atlasFound = true;
				break;
			}
		}
		if (!atlasFound) {
			throw new Error('${SDEConstants.ATLAS_IMAGE_NAME} not found, cannot load this file ');
		}
	}

	private function onProjectAtlasLoaded(event:Event):Void {
		sequenceLoader.removeEventListener(Event.COMPLETE, onProjectAtlasLoaded);

		for (i in 0...loadedZip.getFileCount()) {
			var loadedFileName:String = loadedZip.getFileAt(i).filename;
			if (SDEConstants.isEmitterXMLName(loadedFileName)) {
				var emitterId:String = SDEConstants.getEmitterID(loadedFileName);
				var stardustBA:ByteArray = loadedZip.getFileByName(loadedFileName).content;
				var snapshot:IZipFile = loadedZip.getFileByName(SDEConstants.getParticleSnapshotName(emitterId));

				var rawData:RawEmitterData = new RawEmitterData();
				rawData.emitterID = emitterId;
				rawData.emitterXML = Xml.parse(stardustBA.readUTFBytes(stardustBA.length));
				//trace("rawData emitterXML = " + rawData.emitterXML);
				rawData.snapshot = snapshot != null ? snapshot.content : null;
				rawEmitterDatas.push(rawData);
			}
		}
		var job:LoadByteArrayJob = sequenceLoader.getCompletedJobs().pop();
		var atlasXMLBA:ByteArray = loadedZip.getFileByName(SDEConstants.ATLAS_XML_NAME).content;
		var atlasXML:Xml = Xml.parse(atlasXMLBA.readUTFBytes(atlasXMLBA.length));
		var atlasBD:BitmapData = cast(job.content, Bitmap).bitmapData;
		atlas = new TextureAtlas(Texture.fromBitmapData(atlasBD, false), atlasXML);

		loadedZip = null;
		sequenceLoader.clearAllJobs();
		projectLoaded = true;
		dispatchEvent(new Event(Event.COMPLETE));
	}

	public function createProjectInstance():ProjectValueObject {
		if (!projectLoaded) {
			throw new Error("ERROR: Project is not loaded, call loadSim(), and then wait for the Event.COMPLETE event.");
		}
		var project:ProjectValueObject = new ProjectValueObject(Std.parseFloat(descriptorJSON.version));
		for (rawData in rawEmitterDatas) {
			var emitter:Emitter = EmitterBuilder.buildEmitter(rawData.emitterXML, rawData.emitterID);
			emitter.name = rawData.emitterID;
			var emitterVO:EmitterValueObject = new EmitterValueObject(emitter);
			project.emitters[rawData.emitterID] = emitterVO;
			if (rawData.snapshot != null) {
				emitterVO.emitterSnapshot = rawData.snapshot;
				emitterVO.addParticlesFromSnapshot();
			}
			var allTextures:Vector<SubTexture> = new Vector<SubTexture>();
			var textures:Vector<Texture> = atlas.getTextures(SDEConstants.getSubTexturePrefix(emitterVO.id));
			for (texture in textures) {
				allTextures.push(cast(texture, SubTexture));
			}
			cast(emitterVO.emitter.particleHandler, StarlingHandler).setTextures(allTextures);
		}

		for (em in project.get_emittersArr()) {
			for (action in em.actions) {
				if (Std.isOfType(action, Spawn) && cast(action, Spawn).spawnerEmitterId != null) {
					var spawnAction:Spawn = cast(action, Spawn);
					for (emVO in project.emitters) {
						if (spawnAction.spawnerEmitterId == emVO.id) {
							spawnAction.spawnerEmitter = emVO.emitter;
						}
					}
				}
			}
		}
		return project;
	}

	/* Call this if you don' t want to create more instances of this project to free up its memory and * there are no simulations from this loader running. * Note that this disposes the underlying texture atlas! * After calling it createProjectInstance() will not work. */
	public function dispose():Void {
		sequenceLoader.clearAllJobs();
		projectLoaded = false;
		descriptorJSON = null;
		if (atlas != null) {
			atlas.dispose();
			atlas = null;
		}
		for (rawEmitterData in rawEmitterDatas) {
			if (rawEmitterData.snapshot != null) {
				rawEmitterData.snapshot.clear();
			}
		}
		rawEmitterDatas = new Vector<RawEmitterData>();
	}
}
