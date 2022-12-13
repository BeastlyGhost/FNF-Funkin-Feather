package funkin.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.objects.ui.fonts.Alphabet;
import funkin.song.Conductor;
import funkin.song.MusicState;
import funkin.states.menus.MainMenu;

typedef TitleData =
{
	var bg:String;
	var gf:String;
	var ng:String;
	var bgSize:Float;
	var bgFolder:String;
	var gfFolder:String;
	var ngFolder:String;
	var bgAntialias:Bool;
	var gfAntialias:Bool;
	var ngAntialias:Bool;
	var randomText:Array<Array<String>>;
}

/**
	the game's titlescreen, not much is going on about it aside from some wacky letter stuffs!
**/
class TitleSubstate extends MusicBeatSubstate
{
	var introLines:TitleData;

	var txtContainer:FlxTypedGroup<Alphabet>;
	var textFinal:Array<String> = [];

	var bgBlack:FlxSprite;

	public static var started:Bool = false;

	var skipped:Bool = false;

	var onIntro:Bool = true;

	var gfDance:FlxSprite;
	var logoBump:FlxSprite;
	var ngSpr:FlxSprite;

	var titleEnter:FlxSprite;
	var titleEnterColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleEnterSines:Array<Float> = [1, .64];

	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function create():Void
	{
		super.create();

		introLines = Yaml.read(AssetHandler.grabAsset("titleScreen", YAML, "data/menus"), yaml.Parser.options().useObjects());
		textFinal = FlxG.random.getObject(getText());

		addObjects();

		if (!started)
		{
			DiscordRPC.update("TITLE SCREEN", "Navigating through the Main Menus");

			beginTitle();

			started = true;
		}

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	function addObjects():Void
	{
		var bg:FlxSprite = new FlxSprite();
		if (introLines.bg != null && introLines.bg.length > 1)
		{
			bg.loadGraphic(AssetHandler.grabAsset(introLines.bg, IMAGE, introLines.bgFolder));
			bg.setGraphicSize(Std.int(bg.width * introLines.bgSize));
			bg.antialiasing = introLines.bgAntialias;
			bg.updateHitbox();
		}
		else
			bg.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(bg);

		// gf
		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = AssetHandler.grabAsset(introLines.gf, SPARROW, introLines.gfFolder);
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = introLines.gfAntialias;
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
		titleEnter.antialiasing = introLines.bgAntialias;
		titleEnter.animation.play('static');
		titleEnter.updateHitbox();
		add(titleEnter);

		ngSpr = new FlxSprite(0, FlxG.height * 0.52);
		ngSpr.loadGraphic(AssetHandler.grabAsset(introLines.ng, IMAGE, introLines.ngFolder));
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);

		logoBump = new FlxSprite(-10, 10);
		logoBump.loadGraphic(AssetHandler.grabAsset('logo', IMAGE, "images/menus/titleScreen"));
		add(logoBump);
	}

	function beginTitle():Void
	{
		//
		if (!skipped)
		{
			bgBlack = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
			add(bgBlack);

			txtContainer = new FlxTypedGroup<Alphabet>();
			add(txtContainer);

			ngSpr.visible = false;
			add(ngSpr);
		}
	}

	override function update(elapsed:Float):Void
	{
		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);

		if (!skipped)
		{
			if (newTitle)
			{
				titleTimer += FeatherTools.boundTo(elapsed, 0, 1);
				if (titleTimer > 2)
					titleTimer -= 2;

				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;

				timer = FlxEase.quadInOut(timer);

				if (titleEnter != null)
				{
					titleEnter.color = FlxColor.interpolate(titleEnterColors[0], titleEnterColors[1], timer);
					titleEnter.alpha = FlxMath.lerp(titleEnterSines[0], titleEnterSines[1], timer);
				}
			}

			if (Controls.isJustPressed("accept"))
			{
				if (!onIntro)
				{
					skipped = true;

					if (titleEnter != null)
					{
						titleEnter.color = FlxColor.WHITE;
						titleEnter.alpha = 1;
						titleEnter.animation.play('confirm');
					}

					var color:FlxColor = (OptionsMeta.getPref("Flashing Lights") ? FlxColor.WHITE : FlxColor.BLACK);

					FlxG.camera.flash(color, 1);
					FlxG.sound.play(AssetHandler.grabAsset("confirmMenu", SOUND, "sounds/menus"));

					// give the main menu the heads up that this is done
					MainMenu.firstStart = false;

					for (i in 0...cameras.length)
					{
						FlxTween.tween(cameras[i], {zoom: 1.45, y: 2000}, 2, {
							onComplete: function(t:FlxTween)
							{
								// send it back to the original position
								cameras[i].zoom = 1;
								cameras[i].y = 0;
							},
							ease: FlxEase.expoInOut
						});
					}

					new FlxTimer().start(1.25, function(t:FlxTimer)
					{
						MainMenu.lockedMovement = false;

						MainMenu.instance.updateObjectAlpha(1, true);
						DiscordRPC.update("MAIN MENU", "Navigating through the Main Menus");

						close();
						// MusicState.switchState(new funkin.states.menus.MainMenu());
					});
				}
				else
					endIntro();
			}
		}
	}

	var isRight:Bool = false;
	var logoTween:FlxTween;

	override function beatHit():Void
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

	override function stepHit():Void
	{
		super.stepHit();

		if (onIntro)
		{
			switch (curStep)
			{
				case 4:
					createText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
				case 12:
					addText('PRESENT');
				case 16:
					deleteText();
				case 20:
					createText(['In association', 'with']);
				case 28:
					addText('newgrounds');
					ngSpr.visible = true;
				case 32:
					deleteText();
					ngSpr.visible = false;
				case 36:
					createText([textFinal[0]]);
				case 44:
					addText(textFinal[1]);
				case 48:
					deleteText();
				case 52:
					addText("Friday");
				case 56:
					addText('Night');
				case 60:
					addText("Funkin'");
				case 64:
					endIntro();
			}
		}
	}

	function getText():Array<Array<String>>
	{
		var returnArray:Array<Array<String>> = [];

		for (i in 0...introLines.randomText.length)
		{
			var text:Array<String> = introLines.randomText[i];
			returnArray.push(text);
		}

		return returnArray;
	}

	function createText(textArray:Array<String>):Void
	{
		for (i in 0...textArray.length)
		{
			var initialText:Alphabet = new Alphabet(0, 0, textArray[i], true);
			initialText.screenCenter(X);
			initialText.y += (i * 60) + 200;
			txtContainer.add(initialText);
		}
	}

	function addText(text:String):Void
	{
		var textIntro:Alphabet = new Alphabet(0, 0, text, true);
		textIntro.screenCenter(X);
		textIntro.y += (txtContainer.length * 60) + 200;
		txtContainer.add(textIntro);
	}

	function deleteText():Void
	{
		while (txtContainer.members.length > 0)
			txtContainer.remove(txtContainer.members[0], true);
	}

	function endIntro():Void
	{
		remove(bgBlack);
		remove(txtContainer);
		remove(ngSpr);

		var color:FlxColor = (OptionsMeta.getPref("Flashing Lights") ? FlxColor.WHITE : FlxColor.BLACK);

		FlxG.camera.flash(color, 4);
		onIntro = false;
	}
}
