package funkin.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.backend.dependencies.PlayerInfo;
import funkin.objects.ui.Alphabet;
import funkin.song.MusicState;
import funkin.states.PlayState;
import sys.thread.Mutex;
import sys.thread.Thread;

/**
	a Subclass for when you `pause` on `PlayState`
	initializes simple options with simple functions
**/
class PauseSubstate extends MusicBeatSubstate
{
	var listMap:Map<String, Array<String>> = [
		"default" => ["Resume Song", "Restart Song", "Exit to Options", "Exit to menu"],
		"charting" => ["Exit to Charter", "Leave Charting Mode", "Exit to menu"],
		"no-resume" => ["Restart Song", "Exit to Options", "Exit to menu"],
	];

	var itemContainer:FlxTypedGroup<Alphabet>;

	var pauseMusic:FlxSound;
	var mutex:Mutex;

	public function new(x:Float, y:Float, listName:String = "default"):Void
	{
		super();

		wrappableGroup = listMap.get(listName);

		mutex = new Mutex();
		Thread.create(function()
		{
			mutex.acquire();
			pauseMusic = new FlxSound().loadEmbedded(AssetHandler.grabAsset('breakfast', SOUND, "music"), true, true);
			pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
			FlxG.sound.list.add(pauseMusic);
			pauseMusic.volume = 0;
			mutex.release();
		});

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var stringDiff = FeatherTools.getDifficulty(PlayState.difficulty);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text = FeatherTools.formatSong(PlayState.song.name) + ' [${stringDiff.replace('-', '').toUpperCase()}]';
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(AssetHandler.grabAsset("vcr", FONT, "data/fonts"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDeaths:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDeaths.text = 'Blue balled: ' + PlayerInfo.deaths;
		levelDeaths.scrollFactor.set();
		levelDeaths.setFormat(AssetHandler.grabAsset("vcr", FONT, "data/fonts"), 32);
		levelDeaths.updateHitbox();
		add(levelDeaths);

		levelInfo.alpha = 0;
		levelDeaths.alpha = 0;
		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDeaths.x = FlxG.width - (levelDeaths.width + 20);

		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDeaths, {alpha: 1, y: levelDeaths.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.6});
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

		itemContainer = new FlxTypedGroup<Alphabet>();
		add(itemContainer);

		for (i in 0...wrappableGroup.length)
		{
			var base:Alphabet = new Alphabet(0, (70 * i) + 30, wrappableGroup[i], true);
			base.isMenuItem = true;
			base.targetY = i;
			itemContainer.add(base);
		}

		updateSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (Controls.isJustPressed("up"))
			updateSelection(-1);
		if (Controls.isJustPressed("down"))
			updateSelection(1);

		if (Controls.isJustPressed("accept"))
		{
			var mySelection = wrappableGroup[selection].toLowerCase();

			if (mySelection != "resume song")
				funkin.song.Conductor.stopSong();

			switch (mySelection)
			{
				case "resume song":
					close();
				case "restart song":
					MusicState.resetState();
				case "exit to options":
					MusicState.switchState(new funkin.states.menus.OptionsMenu(true));
				case "exit to charter":
					MusicState.switchState(new funkin.states.editors.ChartEditor());
				case "leave charting mode":
					PlayState.gameplayMode = FREEPLAY;
					MusicState.resetState();
				case "exit to menu":
					PlayerInfo.deaths = 0;

					if (PlayState.gameplayMode == STORY)
						MusicState.switchState(new funkin.states.menus.MainMenu());
					else
						MusicState.switchState(new funkin.states.menus.FreeplayMenu());
			}
		}

		if (pauseMusic != null && pauseMusic.playing)
		{
			if (pauseMusic.volume < 0.5)
				pauseMusic.volume += 0.01 * elapsed;
		}
	}

	override public function updateSelection(newSelection:Int = 0):Void
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
	}

	override function destroy():Void
	{
		if (pauseMusic != null)
			pauseMusic.destroy();
		super.destroy();
	}
}
