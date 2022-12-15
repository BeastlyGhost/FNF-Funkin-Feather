package funkin.substates;

import feather.BaseMenu.BaseSubMenu;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.objects.ui.fonts.Alphabet;

class KeybindsSubstate extends BaseSubMenu
{
	var horizontalContainer:FlxTypedGroup<Alphabet>;

	var generateBG:Bool = false;

	override public function new(generateBG:Bool = false):Void
	{
		super();

		this.generateBG = generateBG;
	}

	override function create():Void
	{
		super.create();

		if (!generateBG)
		{
			menuBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
			menuBG.scrollFactor.set();
			menuBG.alpha = 0.6;
			add(menuBG);
		}
		else
			bgImage = 'menuBGMagenta';

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

		updateSelection(Controls.isJustPressed("up") ? -1 : Controls.isJustPressed("down") ? 1 : 0);

		if (Controls.isJustPressed("back"))
			close();
	}

	override public function updateSelection(newSelection:Int = 0):Void
	{
		super.updateSelection(newSelection);

		var selectionJumper:Int = ((selection < newSelection) ? -1 : 1);

		if (newSelection != 0)
			FeatherTools.playSound("scrollMenu", 'sounds/menus');

		if (itemContainer.members[selection].text == null || itemContainer.members[selection].text == '')
			updateSelection(selection + selectionJumper);
	}

	public function updateHorizontal(newSelection:Int = 0):Void {}
}
