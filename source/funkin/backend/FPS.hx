package funkin.backend;

import flixel.FlxG;
import haxe.Timer;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
	Debug Info class for displaying Framerate and Memory information on screen,
	based on this tutorial https://keyreal-code.github.io/haxecoder-tutorials/17_displaying_fps_and_memory_usage_using_openfl.html
**/
class FPS extends TextField
{
	public var times:Array<Float> = [];
	public var memoryTotal:UInt = 0;

	public function new(x:Float, y:Float):Void
	{
		super();

		this.x = x;
		this.y = y;

		autoSize = LEFT;
		selectable = false;

		defaultTextFormat = new TextFormat(AssetHandler.grabAsset("vcr", FONT, "data/fonts"), 15, -1);
		text = "";

		width = 150;
		height = 70;

		addEventListener(Event.ENTER_FRAME, update);
	}

	static final intervalArray:Array<String> = ['B', 'KB', 'MB', 'GB', 'TB']; // shoutouts to the Myth Engine modders

	inline public static function getInterval(num:UInt):String
	{
		var size:Float = num;
		var data = 0;
		while (size > 1024 && data < intervalArray.length - 1)
		{
			data++;
			size = size / 1024;
		}

		size = Math.round(size * 100) / 100;
		return '$size ${intervalArray[data]}';
	}

	private function update(_:Event):Void
	{
		var now:Float = Timer.stamp();
		times.push(now);
		while (times[0] < now - 1)
			times.shift();

		var memory = System.totalMemory;
		if (memory > memoryTotal)
			memoryTotal = memory;

		if (visible)
		{
			text = ""
				+ (OptionsMeta.getPref("Show FPS Info") ? 'FPS: ${times.length}\n' : '')
				+ (OptionsMeta.getPref("Show RAM Info") ? 'RAM: ${getInterval(memory)} / ${getInterval(memoryTotal)}\n' : '')
				+ (OptionsMeta.getPref("Show Engine Mark") ? 'Funkin\' Feather ${Main.game.version}\n' : '');
		}
	}
}
