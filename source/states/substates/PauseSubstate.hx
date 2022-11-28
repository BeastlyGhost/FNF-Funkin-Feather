package states.substates;

import base.song.MusicState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import objects.Alphabet;
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
		if (Controls.getPressEvent("up"))
			updateSelection(-1);
		if (Controls.getPressEvent("down"))
			updateSelection(1);

		if (Controls.getPressEvent("accept"))
		{
			switch (items[selection])
			{
				case "Resume Song":
					close();
				case "Restart Song":
					MusicState.resetState();
				case "Exit to menu":
					MusicState.switchState(new states.TitleState());
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
