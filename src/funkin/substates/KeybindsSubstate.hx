package funkin.substates;

import feather.BaseMenu.BaseSubMenu;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.objects.ui.fonts.Alphabet;

class KeybindsSubstate extends BaseSubMenu {
	var horizontalContainer:FlxTypedGroup<Alphabet>;

	var generateBG:Bool = false;

	public override function new(generateBG:Bool = false):Void {
		super();

		this.generateBG = generateBG;
	}

	override function create():Void {
		super.create();

		if (!generateBG) {
			menuBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
			menuBG.scrollFactor.set();
			menuBG.alpha = 0.6;
			add(menuBG);
		} else {
			bgImage = 'menuDesat';
			menuBG.color = 0xFFEA71FD;
		}

		itemContainer = generateKeys();

		updateSelection(1);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	function generateKeys():FlxTypedGroup<Alphabet> {
		itemContainer = new FlxTypedGroup<Alphabet>();

		var myKeys:Array<String> = [];

		for (c in Controls.defaultActions.keys())
			myKeys[Controls.defaultActions.get(c).id] = c;

		// trace(myKeys);

		for (i in 0...myKeys.length) {
			if (myKeys[i] == null)
				myKeys[i] = '';

			var keyTxt:Alphabet = new Alphabet(0, 0, myKeys[i], false);

			keyTxt.screenCenter();
			keyTxt.y += (125 * (i - Math.floor(myKeys.length / 2)));

			keyTxt.disableX = true;
			keyTxt.displayStyle = LIST;
			keyTxt.alpha = 0.6;

			itemContainer.add(keyTxt);
		}

		add(itemContainer);

		wrappableGroup = itemContainer.members;

		return itemContainer;
	}

	function generateBinds():FlxTypedGroup<Alphabet> {
		horizontalContainer = new FlxTypedGroup<Alphabet>();

		return horizontalContainer;
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		updateSelection(Controls.isJustPressed("up") ? -1 : Controls.isJustPressed("down") ? 1 : 0);

		if (Controls.isJustPressed("back"))
			close();
	}

	public override function updateSelection(newSelection:Int = 0):Void {
		super.updateSelection(newSelection);

		var selectionJumper:Int = ((newSelection > selection) ? 1 : -1);

		if (newSelection != 0)
			FSound.playSound("scrollMenu", 'sounds/menus');

		if (itemContainer.members[Math.floor(selection)].text == null || itemContainer.members[Math.floor(selection)].text == '')
			updateSelection(Math.floor(selection) + selectionJumper);
	}

	public function updateHorizontal(newSelection:Int = 0):Void {}
}
