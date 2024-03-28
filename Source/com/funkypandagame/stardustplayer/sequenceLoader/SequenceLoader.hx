package com.funkypandagame.stardustplayer.sequenceLoader;

import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.EventDispatcher;

class SequenceLoader extends EventDispatcher implements ISequenceLoader {
	private var waitingJobs:Array<LoadByteArrayJob>;
	private var currentJob:LoadByteArrayJob;
	private var completedJobs:Array<LoadByteArrayJob>;

	public function new() {
		super();
		initialize();
	}

	private function initialize():Void {
		waitingJobs = new Array<LoadByteArrayJob>();
		completedJobs = new Array<LoadByteArrayJob>();
	}

	public function addJob(loadJob:LoadByteArrayJob):Void {
		waitingJobs.push(loadJob);
	}

	public function getCompletedJobs():Array<LoadByteArrayJob> {
		return completedJobs;
	}

	public function getJobContentByName(name:String):DisplayObject {
		var numCompletedJobs:Int = completedJobs.length;
		for (i in 0...numCompletedJobs) {
			if (completedJobs[i].jobName == name) {
				return completedJobs[i].content;
			}
		}
		return null;
	}

	public function getJobByName(name:String):LoadByteArrayJob {
		var numCompletedJobs:Int = completedJobs.length;
		for (i in 0...numCompletedJobs) {
			if (completedJobs[i].jobName == name) {
				return completedJobs[i];
			}
		}
		return null;
	}

	public function removeCompletedJobByName(jobName:String):Void {
		var numCompletedJobs:Int = Std.int(completedJobs.length - 1);
		var i:Int = numCompletedJobs;
		while (i > -1) {
			if (completedJobs[i].jobName == jobName) {
				completedJobs.splice(i, 1);
			}
			i--;
		}
	}

	public function clearAllJobs():Void {
		for (job in completedJobs) {
			job.destroy();
		}
		for (job2 in waitingJobs) {
			job2.destroy();
		}
		waitingJobs = new Array<LoadByteArrayJob>();
		currentJob = null;
		completedJobs = new Array<LoadByteArrayJob>();

		initialize();
	}

	public function loadSequence():Void {
		if (waitingJobs.length > 0) {
			loadNextInSequence();
		} else {
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}

	private function loadNextInSequence():Void {
		if (currentJob != null) {
			completedJobs.unshift(currentJob);
		}
		currentJob = waitingJobs.pop();
		currentJob.addEventListener(Event.COMPLETE, loadComplete);
		currentJob.load();
	}

	private function loadComplete(event:Event):Void {
		currentJob.removeEventListener(Event.COMPLETE, loadComplete);
		if (waitingJobs.length > 0) {
			loadNextInSequence();
		} else {
			completedJobs.unshift(currentJob);
			currentJob = null;
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}
