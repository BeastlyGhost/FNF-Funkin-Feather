package funkin.substates;

import base.utils.PlayerUtils;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
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
		"default" => ["Resume Song", "Restart Song", /*"Exit to Options",*/ "Exit to menu"],
		"charting" => ["Exit to Charter", "Leave Charting Mode", "Exit to menu"],
		"no-resume" => ["Restart Song", /*"Exit to Options",*/ "Exit to menu"],
	];

	var itemContainer:FlxTypedGroup<Alphabet>;

	var pauseMusic:FlxSound;
	var mutex:Mutex;

	public function new(x:Float, y:Float, listName:String = "default")
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

		var stringDiff = funkin.song.ChartParser.difficultyMap.get(PlayState.difficulty);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text = FeatherTools.formatSong(PlayState.song.name) + ' [${stringDiff.replace('-', '').toUpperCase()}]';
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		levelInfo.alpha = 0;
		levelInfo.x = FlxG.width - (levelInfo.width + 20);

		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
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

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Controls.getPressEvent("ui_up"))
			updateSelection(-1);
		if (Controls.getPressEvent("ui_down"))
			updateSelection(1);

		if (Controls.getPressEvent("accept"))
		{
			switch (wrappableGroup[selection].toLowerCase())
			{
				case "resume song":
					close();
				case "restart song":
					funkin.song.Conductor.stopSong();
					MusicState.resetState();
				case "exit to options":
				//
				case "exit to charter":
					MusicState.switchState(new funkin.states.editors.ChartEditor());
				case "leave charting mode":
					funkin.song.Conductor.stopSong();
					PlayState.gameplayMode = FREEPLAY;
					MusicState.resetState();
				case "exit to menu":
					PlayerUtils.deaths = 0;

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
	}

	override function destroy()
	{
		if (pauseMusic != null)
			pauseMusic.destroy();
		super.destroy();
	}
}
