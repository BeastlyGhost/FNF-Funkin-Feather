package states.substates;

import base.song.MusicState;
import base.utils.PlayerUtils;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import objects.ui.Alphabet;
import sys.thread.Mutex;
import sys.thread.Thread;

/**
	a Subclass for when you `pause` on `PlayState`
	initializes simple options with simple functions
**/
class PauseSubstate extends MusicBeatSubstate
{
	var items:Array<String> = ["Resume Song", "Restart Song", "Exit to menu"];
	var itemContainer:FlxTypedGroup<Alphabet>;

	var pauseMusic:FlxSound;
	var mutex:Mutex;

	public function new(x:Float, y:Float)
	{
		super();

		wrappableGroup = items;

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

		var stringDiff = base.song.ChartParser.difficultyMap.get(PlayState.difficulty);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text = FeatherUtils.coolSongFormatter(PlayState.song.name) + ' [${stringDiff.replace('-', '').toUpperCase()}]';
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

		for (i in 0...items.length)
		{
			var base:Alphabet = new Alphabet(0, (70 * i) + 30, items[i], true);
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
			switch (items[selection])
			{
				case "Resume Song":
					close();
				case "Restart Song":
					base.song.Conductor.stopSong();
					MusicState.resetState();
				case "Exit to menu":
					PlayerUtils.deaths = 0;

					if (PlayState.gameplayMode == STORY)
						MusicState.switchState(new states.menus.MainMenu());
					else
						MusicState.switchState(new states.menus.FreeplayMenu());
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
		if (itemContainer.members != null)
		{
			for (i in 0...itemContainer.members.length)
				itemContainer.members[i].destroy();
		}
		if (pauseMusic != null)
			pauseMusic.destroy();
		super.destroy();
	}
}
