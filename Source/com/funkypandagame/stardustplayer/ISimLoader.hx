package com.funkypandagame.stardustplayer;

import com.funkypandagame.stardustplayer.project.ProjectValueObject;
import openfl.events.IEventDispatcher;
import openfl.utils.ByteArray;

interface ISimLoader extends IEventDispatcher {
	function loadSim(data:ByteArray):Void;

	function createProjectInstance():ProjectValueObject;

	function dispose():Void;
}
