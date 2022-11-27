package states;

import base.song.Conductor;
import base.song.MusicState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import objects.Alphabet;

typedef TitleIntroText =
{
	@:optional var bg:String;
	@:optional var gf:String;
	@:optional var bgFolder:String;
	@:optional var gfFolder:String;
	@:optional var bgAntialias:Bool;
	@:optional var gfAntialias:Bool;

	@:optional var stepText:IntroLines;
	@:optional var linesRandom:Array<String>; // replaces "introText.txt"
}

typedef IntroLines =
{
	var steps:Array<Int>;
	var lines:Array<String>;
	var showRandom:Bool; // overrides "lines"
}

class TitleState extends MusicBeatState
{
	// temporary, this is gonna be a json on the assets folder later
	var introLines:TitleIntroText = {
		gf: "title/gfDanceTitle",
		gfFolder: "images/menus",
		bgAntialias: true,
		gfAntialias: true,
	};
	var introTxt:Array<Alphabet>;

	var started:Bool = false;
	var skipped:Bool = false;

	var gfDance:FlxSprite;
	var titleEnter:FlxSprite;

	override function create()
	{
		super.create();

		if (!started)
		{
			FlxG.sound.playMusic(AssetHandler.grabAsset("freakyMenu", SOUND, "music"));
			FlxG.sound.music.volume = 0;
			FlxG.sound.music.looped = true;
			FlxG.sound.music.persist = true;

			FlxG.sound.music.fadeIn(4, 0, 0.7);
			started = true;
		}

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.scrollFactor.set();
		bg.antialiasing = introLines.bgAntialias;
		add(bg);

		// gf
		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = AssetHandler.grabAsset(introLines.gf, SPARROW, introLines.gfFolder);
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = introLines.gfAntialias;
		add(gfDance);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);

		if (Controls.getPressEvent("accept"))
		{
			FlxG.sound.play(AssetHandler.grabAsset("confirmMenu", SOUND, "sounds/ui/menus"));
			skipped = true;
			/*
				titleEnter.playAnim('confirm');
			**/

			new FlxTimer().start(0.5, t ->
			{
				FlxG.sound.music.fadeOut(0.3);
				PlayState.generateSong('erectployed');
				MusicState.switchState(new PlayState());
			});
		}
	}

	var isRight:Bool = false;

	override function beatHit()
	{
		super.beatHit();

		if (gfDance != null)
		{
			isRight = !isRight;
			gfDance.animation.play('dance' + (isRight ? 'Right' : 'Left'));
		}
	}
}
