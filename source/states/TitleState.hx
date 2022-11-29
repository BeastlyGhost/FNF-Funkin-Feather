package states;

import base.song.Conductor;
import base.song.MusicState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import objects.Alphabet;

/**
	the game's titlescreen, not much is going on about it aside from some wacky letter stuffs!
**/
class TitleState extends MusicBeatState
{
	var introLines:Dynamic;
	var introTxt:FlxGroup;
	var txtRandom:Array<String> = [];

	static var started:Bool = false;
	var skipped:Bool = false;

	var gfDance:FlxSprite;
	var logoBump:FlxSprite;

	var titleEnter:FlxSprite;
	var titleEnterColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleEnterSines:Array<Float> = [1, .64];

	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	var soundMusic:FlxSound;

	override function create()
	{
		super.create();

		FeatherUtils.menuMusicCheck(!started);
		DiscordRPC.update("TITLE SCREEN", "Navigating through the Main Menus");

		if (!started)
		{
			introLines = yaml.Yaml.read(AssetHandler.grabAsset("titleText", YAML, "data/menus"));
			// trace(introLines.get("stepText"));

			started = true;
		}

		// guh
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.scrollFactor.set();
		bg.antialiasing = introLines.get("bgAntialias");
		add(bg);

		// gf
		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = AssetHandler.grabAsset(introLines.get("gf"), SPARROW, introLines.get("gfFolder"));
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = introLines.get("gfAntialias");
		add(gfDance);

		titleEnter = new FlxSprite(100, FlxG.height * 0.8);
		titleEnter.frames = AssetHandler.grabAsset('titleScreen/titleEnter', SPARROW, "images/menus");
		var animFrames:Array<FlxFrame> = [];
		@:privateAccess {
			titleEnter.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleEnter.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}

		if (animFrames.length > 0)
		{
			newTitle = true;
			titleEnter.animation.addByPrefix('static', "ENTER IDLE", 24);
			titleEnter.animation.addByPrefix('confirm', OptionsMeta.getPref("Flashing Lights") ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else
		{
			newTitle = false;
			titleEnter.animation.addByPrefix('static', "Press Enter to Begin", 24);
			titleEnter.animation.addByPrefix('confirm', "ENTER PRESSED", 24);
		}
		titleEnter.antialiasing = introLines.get("bgAntialias");
		titleEnter.animation.play('static');
		titleEnter.updateHitbox();
		add(titleEnter);

		logoBump = new FlxSprite(-10, 10);
		logoBump.loadGraphic(AssetHandler.grabAsset('logo', IMAGE, "images/menus/titleScreen"));
		add(logoBump);
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
				titleEnter.color = FlxColor.WHITE;
				titleEnter.alpha = 1;
				titleEnter.animation.play('confirm');

				FlxG.sound.play(AssetHandler.grabAsset("confirmMenu", SOUND, "sounds/menus"));
				skipped = true;

				new FlxTimer().start(1, t ->
				{
					MusicState.switchState(new states.menus.MainMenu());
				});
			}
		}
	}

	var isRight:Bool = false;
	var logoTween:FlxTween;

	override function beatHit()
	{
		super.beatHit();

		if (gfDance != null)
		{
			isRight = !isRight;
			gfDance.animation.play('dance' + (isRight ? 'Right' : 'Left'));
		}

		if (logoBump != null)
		{
			if (logoTween != null)
				logoTween.cancel();
			logoBump.scale.set(1, 1);
			logoTween = FlxTween.tween(logoBump, {'scale.x': 0.9, 'scale.y': 0.9}, 60 / Conductor.bpm, {ease: FlxEase.expoOut});
		}
	}
}
