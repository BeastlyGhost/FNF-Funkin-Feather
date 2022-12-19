package funkin.objects;

import feather.tools.FeatherModule;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import funkin.states.PlayState;

/**
	a Stage Class, used *specifically* for stage spawning during gameplay
**/
class Stage extends FlxTypedGroup<FlxBasic>
{
	public var stageName(never, set):String;
	public var cameraZoom(never, set):Float;

	public function set_stageName(dummyStage:String = "unknown"):String
	{
		if (PlayState.song != null && PlayState.song.stage != null)
			dummyStage = PlayState.song.stage;
		else
		{
			// ninjamuffin bullshit go!
			switch (PlayState.song.internalName.toLowerCase().replace(' ', '-'))
			{
				case "bopeebo" | "fresh" | "dadbattle" | "dad-battle":
					dummyStage = "stage";
				case "spookeez" | "south" | "monster":
					dummyStage = "haunted-house";
				case "pico" | "philly" | "philly-nice" | "blammed":
					dummyStage = "philly-city";
				case "satin-panties" | "high" | "milf":
					dummyStage = "highway";
				case "cocoa" | "eggnog":
					dummyStage = "mall";
				case "winter-horrorland":
					dummyStage = "mall-illusion";
				case "senpai" | "roses":
					dummyStage = "school";
				case "thorns":
					dummyStage = "school-glitch";
				case "ugh" | "guns" | "stress":
					dummyStage = "military";
				default:
					dummyStage = "unknown";
			}
		}

		PlayState.curStage = dummyStage;

		return dummyStage;
	}

	function set_cameraZoom(zoom:Float):Float
	{
		PlayState.cameraZoom = zoom;
		return zoom;
	}

	public var stageModule:FeatherModule;

	public var playerPos:FlxPoint;
	public var opponentPos:FlxPoint;
	public var crowdPos:FlxPoint;

	public function new():Void
	{
		super();

		playerPos = new FlxPoint(770, 450);
		opponentPos = new FlxPoint(100, 100);
		crowdPos = new FlxPoint(400, 130);
	}

	public function setStage(newStage:String = "unknown"):Stage
	{
		this.stageName = newStage;

		switch (newStage)
		{
			default:
				cameraZoom = 0.9;

				try
				{
					//
					callStageModule(newStage);
				}
				catch (e)
				{
					trace('Module "$newStage" not found.');
				}
		}

		return this;
	}

	public function getStageCrowd(stageName:String):String
	{
		var dummyCrowd:String = 'gf';

		if (PlayState.song != null && PlayState.song.crowd != null)
			dummyCrowd = PlayState.song.crowd;
		else
		{
			switch (stageName.toLowerCase().replace(' ', '-'))
			{
				case "highway":
					dummyCrowd = "gf-car";
				case "mall" | "mall-illusion":
					dummyCrowd = "gf-christmas";
				case "school" | "school-glitch":
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

		return dummyCrowd;
	}

	public function stageCountdownTick(count:Int):Void
	{
		callFunc('onTick', [count]);
	}

	public function stageUpdate(elapsed:Float):Void
	{
		callFunc('onUpdate', [elapsed]);
	}

	public function stageStepHit(curStep:Int):Void
	{
		callFunc('onStep', [curStep]);
	}

	public function stageBeatHit(curBeat:Int):Void
	{
		callFunc('onBeat', [curBeat]);
	}

	public function stageSectionHit(curSec:Int):Void
	{
		callFunc('onSection', [curSec]);
	}

	public function callStageModule(stageName:String):Void
	{
		var modulePath = AssetHelper.grabAsset('$stageName', MODULE, 'data/stages/$stageName');

		if (!sys.FileSystem.exists(modulePath))
			return;

		stageModule = new FeatherModule(modulePath);

		/* ===== SCRIPT VARIABLES ===== */

		setVar('add', add);
		setVar('remove', remove);
		setVar('game', PlayState.main);

		if (PlayState.song != null)
			setVar('songName', PlayState.song.name.toLowerCase());

		if (PlayState.player != null)
		{
			setVar('bf', PlayState.player);
			setVar('boyfriend', PlayState.player);
			setVar('player', PlayState.player);

			setVar('bfName', PlayState.player.character);
			setVar('boyfriendName', PlayState.player.character);
			setVar('playerName', PlayState.player.character);
		}

		if (PlayState.opponent != null)
		{
			setVar('dad', PlayState.opponent);
			setVar('dadOpponent', PlayState.opponent);
			setVar('opponent', PlayState.opponent);

			setVar('dadName', PlayState.opponent.character);
			setVar('dadOpponentName', PlayState.opponent.character);
			setVar('opponentName', PlayState.opponent.character);
		}

		callFunc('onCreate', []);
	}

	public function callFunc(key:String, args:Array<Dynamic>)
	{
		if (stageModule == null)
			return null;
		else
			return stageModule.call(key, args);
	}

	public function setVar(key:String, value:Dynamic)
	{
		if (stageModule == null)
			return null;
		else
			return stageModule.set(key, value);
	}
}
