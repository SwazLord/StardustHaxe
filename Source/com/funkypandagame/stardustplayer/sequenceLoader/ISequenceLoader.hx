package com.funkypandagame.stardustplayer.sequenceLoader;

import openfl.Vector;
import openfl.display.DisplayObject;
import openfl.events.IEventDispatcher;

interface ISequenceLoader extends IEventDispatcher {
	function addJob(loadJob:LoadByteArrayJob):Void;

	function getCompletedJobs():Vector<LoadByteArrayJob>;

	function getJobContentByName(emitterName:String):DisplayObject;

	function getJobByName(emitterName:String):LoadByteArrayJob;

	function removeCompletedJobByName(jobName:String):Void;

	function clearAllJobs():Void;

	function loadSequence():Void;
}
