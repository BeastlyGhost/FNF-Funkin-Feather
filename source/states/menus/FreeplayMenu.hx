package states.menus;

import base.song.MusicState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import objects.ui.Alphabet;
import sys.thread.Mutex;

typedef SongData =
{
	var name:String;
	var week:Int;
	var character:String;
	var color:Int; // should this be an array? huh.. @BeastlyGhost
}

/**
	the Freeplay Menu, for selecting and playing songs!

	when selecting songs here, things like the Chart Editor will be allowed during gameplay
**/
class FreeplayMenu extends MusicBeatState
{
	var itemContainer:FlxTypedGroup<Alphabet>;

	@:isVar var songList(get, default):Array<SongData> = [];

	var songNameList:Array<String> = [];

	function get_songList():Array<SongData>
	{
		var songs:Array<String> = [];
		var songsFolder = sys.FileSystem.readDirectory('assets/songs');

		for (folder in songsFolder)
			if (!folder.contains('.'))
				songs.push(folder);

		for (i in 0...songs.length)
		{
			if (!songNameList.contains(songs[i]))
			{
				songList.push({
					name: songs[i],
					week: 1,
					character: 'bf',
					color: -1
				});
				songNameList.push(songs[i]);
			}
		}

		return songList;
	}

	var difficultySelection:Int = -1;
	var songInst:FlxSound;
	var songVocals:FlxSound;

	var menuBG:FlxSprite;
	var scoreBG:FlxSprite;
	var scoreTxt:FlxText;
	var diffTxt:FlxText;

	var mutex:Mutex;

	var tempColors = [0xFFFFB300, 0xFF56AEBD, 0xFF9F5788, 0xFFC35D5D];

	override function create()
	{
		super.create();

		DiscordRPC.update("FREEPLAY MENU", "Choosing a Song");

		menuBG = new FlxSprite(-80).loadGraphic(Paths.image('menus/menuDesat'));
		menuBG.scrollFactor.set();
		menuBG.screenCenter(X);
		add(menuBG);

		generateUI();

		wrappableGroup = songList;

		updateSelection();
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

		scoreTxt = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		diffTxt = new FlxText(scoreTxt.x, scoreTxt.y + 36, 0, "", 24);
		scoreBG = new FlxSprite(scoreTxt.x - 6, 0).makeGraphic(1, 66, 0xFF000000);

		scoreTxt.setFormat(AssetHandler.grabAsset("vcr", FONT, "data/fonts"), 32, 0xFFFFFFFF, RIGHT);
		diffTxt.setFormat(AssetHandler.grabAsset("vcr", FONT, "data/fonts"), 24, 0xFFFFFFFF, RIGHT);

		scoreBG.antialiasing = false;
		scoreBG.alpha = 0.6;
		add(scoreBG);

		add(diffTxt);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (scoreTxt != null)
			scoreTxt.text = "PERSONAL BEST: 0";

		if (menuBG != null && menuBG.pixels != null)
			menuBG.color = FlxColor.interpolate(menuBG.color, tempColors[selection]);

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * elapsed;

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
			PlayState.songName = songList[selection].name;
			PlayState.gameplayMode = FREEPLAY;
			PlayState.difficulty = difficultySelection;

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

		if (newSelection != 0)
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

		updateDifficulty();
	}

	function updateDifficulty(newDifficulty:Int = 0)
	{
		difficultySelection = FlxMath.wrap(Math.floor(difficultySelection) + newDifficulty, 0, 2);

		var stringDiff = base.song.ChartParser.difficultyMap.get(difficultySelection);

		diffTxt.text = '< ${stringDiff.replace('-', '').toUpperCase()} >';
		repositionScore();
	}
}
