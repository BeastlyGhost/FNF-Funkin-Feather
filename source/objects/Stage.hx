package objects;

import base.utils.FeatherUtils.FeatherSprite;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import states.PlayState;

/**
	a Stage Class, used *specifically* for stage spawning during gameplay
**/
class Stage extends FlxTypedGroup<FlxBasic>
{
	public var curStage:String;
	public var cameraZoom:Float = 1.05;

	public function new()
	{
		super();
	}

	public function setStage(?curStage:String)
	{
		if (curStage == null)
			curStage = "unknown";

		switch (curStage)
		{
			default:
				cameraZoom = 0.9;
		}
	}

	public function getStageName()
	{
		var dummyStage:String = "unknown";

		if (PlayState.song != null)
		{
			if (PlayState.song.stage != null)
				dummyStage = PlayState.song.stage;
			else
			{
				// ninjamuffin bullshit go!
				switch (PlayState.song.internalName.toLowerCase())
				{
					case "bopeebo" | "fresh" | "dadbattle" | "dad-battle":
						dummyStage = "stage";
					case "spookeez" | "south" | "monster":
						dummyStage = "spooky";
					case "pico" | "philly" | "philly-nice" | "blammed":
						dummyStage = "philly";
					case "satin-panties" | "high" | "milf":
						dummyStage = "highway";
					case "cocoa" | "eggnog":
						dummyStage = "mall";
					case "winter-horrorland":
						dummyStage = "mallEvil";
					case "senpai" | "roses":
						dummyStage = "school";
					case "thorns":
						dummyStage = "schoolEvil";
					case "ugh" | "guns" | "stress":
						dummyStage = "military";
				}
			}
		}

		return dummyStage;
	}

	public function getStageCrowd()
	{
		var dummyCrowd:String = 'gf';

		if (PlayState.song != null)
		{
			if (PlayState.song.crowd != null)
				dummyCrowd = PlayState.song.crowd;
			else
			{
				switch (curStage.toLowerCase())
				{
					case "highway":
						dummyCrowd = "gf-car";
					case "mall" | "mallEvil":
						dummyCrowd = "gf-christmas";
					case "school" | "schoolEvil":
						dummyCrowd = "gf-pixel";
					case "military":
						if (PlayState.song.internalName.toLowerCase() == "stress")
							dummyCrowd = "pico-speaker";
						else
							dummyCrowd = "gf-tankmen";
					default:
						dummyCrowd = "gf";
				}
			}
		}

		return dummyCrowd;
	}

	public function stageCountdownTick(count:Int, player:Character, opponent:Character, crowd:Character) {}

	public function stageUpdate(elapsed:Float, player:Character, opponent:Character, crowd:Character) {}

	public function stageStepHit(curStep:Int, player:Character, opponent:Character, crowd:Character) {}

	public function stageBeatHit(curBeat:Int, player:Character, opponent:Character, crowd:Character) {}

	public function stageSectionHit(curSec:Int, player:Character, opponent:Character, crowd:Character) {}
}
