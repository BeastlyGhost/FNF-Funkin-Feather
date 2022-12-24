package funkin.states.menus;

import feather.BaseMenu;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.essentials.PlayerInfo;
import funkin.essentials.song.MusicState;
import funkin.essentials.song.SongManager;
import funkin.objects.ui.Icon;
import funkin.objects.ui.fonts.Alphabet;
import openfl.media.Sound;

/**
	the Freeplay Menu, for selecting and playing songs!

	when selecting songs here, things like the Chart Editor will be allowed during gameplay
**/
class FreeplayMenu extends BaseMenu {
	var songList:Array<SongListForm> = [];

	var iconContainer:Array<Icon> = [];

	var songRating:Float = 1;

	static var selDifficulty:Int = 1;

	var songInst:FlxSound;
	var songVocals:FlxSound;

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var inst:Sound;
	var vocals:Sound;

	var scoreBG:FlxSprite;
	var scoreTxt:FlxText;
	var diffTxt:FlxText;
	var rateTxt:FlxText;

	override function create():Void {
		super.create();

		bgImage = 'menuDesat';

		DiscordRPC.update("FREEPLAY MENU", "Choosing a Song");

		FeatherUtils.menuMusicCheck(false);

		// get the song list
		songList = SongManager.get_songList();

		funkin.essentials.song.Conductor.songRate = songRating;

		generateUI();
	}

	function generateUI():Void {
		itemContainer = new FlxTypedGroup<Alphabet>();
		add(itemContainer);

		for (i in 0...songList.length) {
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songList[i].name, false);
			songText.displayStyle = LIST;
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

		scoreTxt.setFormat(AssetHelper.grabAsset("vcr", FONT, "data/fonts"), 32, 0xFFFFFFFF, RIGHT);
		diffTxt.setFormat(AssetHelper.grabAsset("vcr", FONT, "data/fonts"), 24, 0xFFFFFFFF, RIGHT);
		#if (flixel >= "5.0.0")
		rateTxt.setFormat(AssetHelper.grabAsset("vcr", FONT, "data/fonts"), 24, 0xFFFFFFFF, RIGHT);
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

	override function update(elapsed:Float):Void {
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
			menuBG.color = FlxColor.interpolate(menuBG.color, songList[Math.floor(selection)].color);

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * elapsed;

		repositionScore();

		updateSelection(Controls.isJustPressed("up") ? -1 : Controls.isJustPressed("down") ? 1 : 0);

		if (!FlxG.keys.pressed.SHIFT)
			updateDifficulty(Controls.isJustPressed("left") ? -1 : Controls.isJustPressed("right") ? 1 : 0);

		#if (flixel >= "5.0.0")
		if (FlxG.keys.pressed.SHIFT)
			songRating += Controls.isJustPressed("left") ? -0.05 : Controls.isJustPressed("right") ? 0.05 : 0;

		// stupid wrapper
		if (songRating > 3)
			songRating = 3;
		if (songRating < 0.5)
			songRating = 0.5;
		#end

		if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.R)
			songRating = 1;

		if (Controls.isJustPressed("back")) {
			MusicState.switchState(new MainMenu());
			FSound.playSound("cancelMenu", "sounds/menus");
		}

		if (Controls.isJustPressed("accept")) {
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();

			if (songList[Math.floor(selection)].group != null)
				AssetGroup.activeGroup = songList[Math.floor(selection)].group;
			trace(AssetGroup.activeGroup);

			PlayState.songName = songList[Math.floor(selection)].name;
			PlayState.currentWeek = songList[Math.floor(selection)].week;
			PlayState.difficulty = selDifficulty;
			PlayState.gameplayMode = FREEPLAY;

			#if (flixel >= "5.0.0")
			funkin.essentials.song.Conductor.songRate = songRating;
			#end

			MusicState.switchState(new PlayState());
		}
	}

	function repositionScore():Void {
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

	public override function updateSelection(newSelection:Int = 0):Void {
		super.updateSelection(newSelection);

		for (i in 0...iconContainer.length)
			iconContainer[i].alpha = 0.6;
		iconContainer[Math.floor(selection)].alpha = 1;

		intendedScore = PlayerInfo.getScore(songList[Math.floor(selection)].name, selDifficulty, FREEPLAY);

		updateDifficulty();
	}

	function updateDifficulty(newDifficulty:Int = 0):Void {
		selDifficulty = FlxMath.wrap(selDifficulty + newDifficulty, 0, songList[Math.floor(selection)].diffs.length - 1);

		var stringDiff = FeatherUtils.getDifficulty(selDifficulty);
		diffTxt.text = '< ${stringDiff.replace('-', '').toUpperCase()} >';

		intendedScore = PlayerInfo.getScore(songList[Math.floor(selection)].name, selDifficulty, FREEPLAY);
	}
}
