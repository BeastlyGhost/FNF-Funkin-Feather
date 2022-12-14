package funkin.substates;

import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxObject;
import funkin.song.Conductor;
import funkin.states.PlayState;
import funkin.objects.Character;
import funkin.song.MusicState;

class GameOverSubstate extends MusicBeatSubstate
{
	var char:Character;
	var camFollow:FlxObject;

	public static var preferences:Dynamic = {
		character: "bf-dead",
		sound: "fnf_loss_sfx",
		music: "gameOver",
		confirm: "gameOverEnd",
		bpm: 100
	};

	public static function reset():Void
	{
		preferences = {
			character: "bf-dead",
			sound: "fnf_loss_sfx",
			music: "gameOver",
			confirm: "gameOverEnd",
			bpm: 100
		};
	}

	public function new(x:Float = 0, y:Float = 0):Void
	{
		super();

		Conductor.songPosition = 0;

		char = new Character();
		char.setCharacter(x, y + PlayState.player.height, preferences.character);
		add(char);

		PlayState.player.destroy();

		camFollow = new FlxObject(char.getGraphicMidpoint().x + 20, char.getGraphicMidpoint().y - 40, 1, 1);
		add(camFollow);

		Conductor.changeBPM(preferences.bpm);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		char.playAnim('firstDeath');
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (Controls.isJustPressed("accept"))
			endScene();

		if (char.animation.curAnim.name == 'firstDeath' && char.animation.curAnim.curFrame == 12)
			FlxG.camera.follow(camFollow, LOCKON, 0.01);

		if (char.animation.curAnim.name == 'firstDeath' && char.animation.curAnim.finished)
			FlxG.sound.playMusic(AssetHandler.grabAsset(preferences.music, SOUND, "music"));
	}

	var isEnding:Bool = false;

	function endScene():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			char.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FeatherTools.playSound(preferences.confirm, "music", true);
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(0xFF000000, 1, false, function()
				{
					MusicState.switchState(new PlayState());
				});
			});
		}
	}
}
