package states.substates;

import base.song.MusicState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import objects.Alphabet;

class PauseSubstate extends MusicBeatSubstate
{
	var items:Array<String> = ["Resume Song", "Restart Song", "Exit to menu"];
	var itemContainer:FlxTypedGroup<Alphabet>;
	var pauseMusic:FlxSound;

	public function new(x:Float, y:Float)
	{
		super();

		wrappableGroup = items;

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
}
