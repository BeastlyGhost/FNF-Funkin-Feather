package states;

import base.song.Conductor;
import base.song.MusicState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
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
	var titleEnterColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleEnterSines:Array<Float> = [1, .64];

	var newTitle:Bool = false;
	var titleTimer:Float = 0;

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
			Conductor.changeBPM(102);

			started = true;
		}

		// guh
		persistentUpdate = true;

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

		titleEnter = new FlxSprite(100, FlxG.height * 0.8);
		titleEnter.frames = AssetHandler.grabAsset('title/titleEnter', SPARROW, "images/menus");
		var animFrames:Array<FlxFrame> = [];
		@:privateAccess {
			titleEnter.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleEnter.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}

		if (animFrames.length > 0)
		{
			newTitle = true;
			titleEnter.animation.addByPrefix('static', "ENTER IDLE", 24);
			titleEnter.animation.addByPrefix('confirm', Start.getPref("Flashing Lights") ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else
		{
			newTitle = false;
			titleEnter.animation.addByPrefix('static', "Press Enter to Begin", 24);
			titleEnter.animation.addByPrefix('confirm', "ENTER PRESSED", 24);
		}
		titleEnter.antialiasing = introLines.bgAntialias;
		titleEnter.animation.play('static');
		titleEnter.updateHitbox();
		add(titleEnter);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);

		if (!skipped)
		{
			if (newTitle)
			{
				titleTimer += FeatherUtils.boundTo(elapsed, 0, 1);
				if (titleTimer > 2)
					titleTimer -= 2;

				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;

				timer = FlxEase.quadInOut(timer);

				titleEnter.color = FlxColor.interpolate(titleEnterColors[0], titleEnterColors[1], timer);
				titleEnter.alpha = FlxMath.lerp(titleEnterSines[0], titleEnterSines[1], timer);
			}

			if (Controls.getPressEvent("accept"))
			{
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				titleEnter.color = FlxColor.WHITE;
				titleEnter.alpha = 1;
				titleEnter.animation.play('confirm');

				FlxG.sound.play(AssetHandler.grabAsset("confirmMenu", SOUND, "sounds/ui/menus"));
				skipped = true;

				new FlxTimer().start(1, t ->
				{
					FlxG.sound.music.fadeOut(0.3);

					PlayState.songName = "erectployed";
					PlayState.gameplayMode = FREEPLAY;
					PlayState.difficulty = 1;

					MusicState.switchState(new PlayState());
				});
			}
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
