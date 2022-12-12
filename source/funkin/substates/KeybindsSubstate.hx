package funkin.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.objects.ui.fonts.Alphabet;
import funkin.song.MusicState;

class KeybindsSubstate extends MusicBeatSubstate
{
	var itemContainer:FlxTypedGroup<Alphabet>;
	var horizontalContainer:FlxTypedGroup<Alphabet>;

	override function create():Void
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		itemContainer = generateKeys();

		updateSelection(1);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	function generateKeys():FlxTypedGroup<Alphabet>
	{
		itemContainer = new FlxTypedGroup<Alphabet>();

		var myKeys:Array<String> = [];

		for (c in Controls.defaultActions.keys())
			myKeys[Controls.defaultActions.get(c).id] = c;

		// trace(myKeys);

		for (i in 0...myKeys.length)
		{
			if (myKeys[i] == null)
				myKeys[i] = '';

			var keyTxt:Alphabet = new Alphabet(0, 0, myKeys[i], true);
			keyTxt.screenCenter();

			keyTxt.targetY = i;
			keyTxt.y += (125 * (i - Math.floor(myKeys.length / 2)));

			keyTxt.alpha = 0.6;
			keyTxt.disableX = true;
			keyTxt.isMenuItem = true;

			itemContainer.add(keyTxt);
		}

		add(itemContainer);

		wrappableGroup = itemContainer.members;

		return itemContainer;
	}

	function generateBinds():FlxTypedGroup<Alphabet>
	{
		horizontalContainer = new FlxTypedGroup<Alphabet>();

		return horizontalContainer;
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (Controls.isJustPressed("up"))
			updateSelection(-1);
		if (Controls.isJustPressed("down"))
			updateSelection(1);

		if (Controls.isJustPressed("back"))
			close();
	}

	override public function updateSelection(newSelection:Int = 0):Void
	{
		super.updateSelection(newSelection);

		var selectionJumper = ((newSelection > selection) ? 1 : -1);

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

		if (itemContainer.members[selection].text == null || itemContainer.members[selection].text == '')
			updateSelection(selection + selectionJumper);
	}

	public function updateHorizontal(newSelection:Int = 0):Void {}
}
