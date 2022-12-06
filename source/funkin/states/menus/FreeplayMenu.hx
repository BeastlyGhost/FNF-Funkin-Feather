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
import funkin.objects.ui.Alphabet;
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

	var tempColors = [0xFFFFB300, 0xFF56AEBD, 0xFF9F5788, 0xFFC35D5D];

	override function create()
	{
		super.create();

		DiscordRPC.update("FREEPLAY MENU", "Choosing a Song");

		// get the song list
		songList = SongManager.get_songList();

		menuBG = new FlxSprite(-80).loadGraphic(AssetHandler.grabAsset('menuDesat', IMAGE, 'images/menus'));
		menuBG.scrollFactor.set();
		menuBG.screenCenter(X);
		add(menuBG);

		generateUI();
	}

	function generateUI()
	{
		itemContainer = new FlxTypedGroup<Alphabet>();
		add(itemContainer);

		for (i in 0...songList.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songList[i].name, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			itemContainer.add(songText);
		}

		wrappableGroup = songList;

		scoreTxt = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		diffTxt = new FlxText(scoreTxt.x, scoreTxt.y + 36, 0, "", 24);
		scoreBG = new FlxSprite(scoreTxt.x - 6, 0).makeGraphic(1, 66, 0xFF000000);

		scoreTxt.setFormat(AssetHandler.grabAsset("vcr", FONT, "data/fonts"), 32, 0xFFFFFFFF, RIGHT);
		diffTxt.setFormat(AssetHandler.grabAsset("vcr", FONT, "data/fonts"), 24, 0xFFFFFFFF, RIGHT);

		scoreBG.antialiasing = false;
		scoreBG.alpha = 0.6;
		add(scoreBG);

		add(diffTxt);

		updateSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		if (scoreTxt != null)
			scoreTxt.text = "PERSONAL BEST: " + lerpScore;

		if (menuBG != null && menuBG.pixels != null)
			menuBG.color = FlxColor.interpolate(menuBG.color, tempColors[selection]);

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * elapsed;

		repositionScore();

		if (Controls.getPressEvent("ui_up"))
			updateSelection(-1);
		if (Controls.getPressEvent("ui_down"))
			updateSelection(1);

		if (Controls.getPressEvent("ui_left"))
			updateDifficulty(-1);
		if (Controls.getPressEvent("ui_right"))
			updateDifficulty(1);

		if (Controls.getPressEvent("back"))
			MusicState.switchState(new MainMenu());

		if (Controls.getPressEvent("accept"))
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();

			PlayState.songName = songList[selection].name;
			PlayState.currentWeek = songList[selection].week;
			PlayState.difficulty = selDifficulty;
			PlayState.gameplayMode = FREEPLAY;

			MusicState.switchState(new PlayState());
		}
	}

	function repositionScore()
	{
		// from the base game
		scoreTxt.x = FlxG.width - scoreTxt.width - 6;
		scoreBG.scale.x = FlxG.width - scoreTxt.x + 6;
		scoreBG.x = FlxG.width - scoreBG.scale.x / 2;
		diffTxt.x = scoreBG.x + scoreBG.width / 2;
		diffTxt.x -= diffTxt.width / 2;
	}

	override public function updateSelection(newSelection:Int = 0)
	{
		super.updateSelection(newSelection);

		FlxG.sound.play(AssetHandler.grabAsset('scrollMenu', SOUND, "sounds/menus"));

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

	function updateDifficulty(newDifficulty:Int = 0)
	{
		selDifficulty = FlxMath.wrap(Math.floor(selDifficulty) + newDifficulty, 0, songList[selection].diffs.length - 1);

		var stringDiff = FeatherTools.getDifficulty(selDifficulty);
		diffTxt.text = '< ${stringDiff.replace('-', '').toUpperCase()} >';

		intendedScore = PlayerInfo.getScore(songList[selection].name, selDifficulty, false);
	}
}
