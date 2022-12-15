package funkin.states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.backend.data.SongManager;
import funkin.backend.dependencies.PlayerInfo;
import funkin.objects.ui.Icon;
import funkin.objects.ui.fonts.Alphabet;
import funkin.song.MusicState;
import openfl.media.Sound;

/**
	the Freeplay Menu, for selecting and playing songs!

	when selecting songs here, things like the Chart Editor will be allowed during gameplay
**/
class FreeplayMenu extends MusicBeatState
{
	var songList:Array<SongListForm> = [];

	var itemContainer:FlxTypedGroup<Alphabet>;

	var iconContainer:Array<Icon> = [];

	var songRating:Float = 1;

	static var selDifficulty:Int = 1;

	var songInst:FlxSound;
	var songVocals:FlxSound;

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var inst:Sound;
	var vocals:Sound;

	var menuBG:FlxSprite;
	var scoreBG:FlxSprite;
	var scoreTxt:FlxText;
	var diffTxt:FlxText;
	var rateTxt:FlxText;

	var tempColors = [0xFFFFB300, 0xFF56AEBD, 0xFF9F5788, 0xFFC35D5D];

	override function create():Void
	{
		super.create();

		DiscordRPC.update("FREEPLAY MENU", "Choosing a Song");

		FeatherTools.menuMusicCheck(false);

		// get the song list
		songList = SongManager.get_songList();

		funkin.song.Conductor.songRate = songRating;

		menuBG = new FlxSprite(-80).loadGraphic(AssetHandler.grabAsset('menuDesat', IMAGE, 'images/menus'));
		menuBG.scrollFactor.set();
		menuBG.screenCenter(X);
		add(menuBG);

		generateUI();
	}

	function generateUI():Void
	{
		itemContainer = new FlxTypedGroup<Alphabet>();
		add(itemContainer);

		for (i in 0...songList.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songList[i].name, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			itemContainer.add(songText);

			var songIcon:Icon = new Icon(songList[i].character);
			songIcon.parentSprite = songText;
			iconContainer.push(songIcon);
			add(songIcon);
		}

		wrappableGroup = songList;

		scoreTxt = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		diffTxt = new FlxText(scoreTxt.x, scoreTxt.y + 36, 0, "", 24);
		#if (flixel >= "5.0.0")
		rateTxt = new FlxText(diffTxt.x, diffTxt.y + 36, 0, "", 24);
		#end
		scoreBG = new FlxSprite(scoreTxt.x - 6, 0).makeGraphic(1, #if (flixel >= "5.0.0") 106 #else 66 #end, 0xFF000000);

		scoreTxt.setFormat(AssetHandler.grabAsset("vcr", FONT, "data/fonts"), 32, 0xFFFFFFFF, RIGHT);
		diffTxt.setFormat(AssetHandler.grabAsset("vcr", FONT, "data/fonts"), 24, 0xFFFFFFFF, RIGHT);
		#if (flixel >= "5.0.0")
		rateTxt.setFormat(AssetHandler.grabAsset("vcr", FONT, "data/fonts"), 24, 0xFFFFFFFF, RIGHT);
		#end

		scoreBG.antialiasing = false;
		scoreBG.alpha = 0.6;
		add(scoreBG);

		add(diffTxt);

		#if (flixel >= "5.0.0")
		add(rateTxt);
		#end

		add(scoreTxt);

		updateSelection();
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		if (scoreTxt != null)
			scoreTxt.text = "PERSONAL BEST: " + lerpScore;

		#if (flixel >= "5.0.0")
		if (rateTxt != null)
			rateTxt.text = 'RATE: ' + songRating + "x";
		#end

		if (menuBG != null && menuBG.pixels != null)
			menuBG.color = FlxColor.interpolate(menuBG.color, tempColors[selection]);

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * elapsed;

		repositionScore();

		if (Controls.isJustPressed("up"))
			updateSelection(-1);
		if (Controls.isJustPressed("down"))
			updateSelection(1);

		if (Controls.isJustPressed("left") && !FlxG.keys.pressed.SHIFT)
			updateDifficulty(-1);
		if (Controls.isJustPressed("right") && !FlxG.keys.pressed.SHIFT)
			updateDifficulty(1);

		#if (flixel >= "5.0.0")
		if (Controls.isJustPressed("left") && FlxG.keys.pressed.SHIFT)
			songRating -= 0.05;
		if (Controls.isJustPressed("right") && FlxG.keys.pressed.SHIFT)
			songRating += 0.05;

		// stupid wrapper
		if (songRating > 3)
			songRating = 3;
		if (songRating < 0.5)
			songRating = 0.5;
		#end

		if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.R)
			songRating = 1;

		if (Controls.isJustPressed("back"))
		{
			MusicState.switchState(new MainMenu());
			FlxG.sound.play(AssetHandler.grabAsset('cancelMenu', SOUND, "sounds/menus"));
		}

		if (Controls.isJustPressed("accept"))
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();

			PlayState.songName = songList[selection].name;
			PlayState.currentWeek = songList[selection].week;
			PlayState.difficulty = selDifficulty;
			PlayState.gameplayMode = FREEPLAY;

			#if (flixel >= "5.0.0")
			funkin.song.Conductor.songRate = songRating;
			#end

			MusicState.switchState(new PlayState());
		}
	}

	function repositionScore():Void
	{
		// from the base game
		scoreTxt.x = FlxG.width - scoreTxt.width - 6;
		scoreBG.scale.x = FlxG.width - scoreTxt.x + 6;
		scoreBG.x = FlxG.width - scoreBG.scale.x / 2;
		diffTxt.x = scoreBG.x + scoreBG.width / 2;
		diffTxt.x -= diffTxt.width / 2;
		#if (flixel >= "5.0.0")
		rateTxt.x = FlxG.width - rateTxt.width;
		#end
	}

	override public function updateSelection(newSelection:Int = 0):Void
	{
		super.updateSelection(newSelection);

		if (newSelection != 0)
			FlxG.sound.play(AssetHandler.grabAsset('scrollMenu', SOUND, "sounds/menus"));

		for (i in 0...iconContainer.length)
			iconContainer[i].alpha = 0.6;

		iconContainer[selection].alpha = 1;

		var blah:Int = 0;
		for (item in itemContainer.members)
		{
			item.targetY = blah - selection;
			blah++;

			item.alpha = 0.6;
			if (item.targetY == 0)
				item.alpha = 1;
		}

		intendedScore = PlayerInfo.getScore(songList[selection].name, selDifficulty, false);

		updateDifficulty();
	}

	function updateDifficulty(newDifficulty:Int = 0):Void
	{
		selDifficulty = FlxMath.wrap(Math.floor(selDifficulty) + newDifficulty, 0, songList[selection].diffs.length - 1);

		var stringDiff = FeatherTools.getDifficulty(selDifficulty);
		diffTxt.text = '< ${stringDiff.replace('-', '').toUpperCase()} >';

		intendedScore = PlayerInfo.getScore(songList[selection].name, selDifficulty, false);
	}
}
