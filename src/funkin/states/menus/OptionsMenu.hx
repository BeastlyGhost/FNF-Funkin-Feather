package funkin.states.menus;

import feather.BaseMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.essentials.song.MusicState;
import funkin.objects.ui.fonts.Alphabet;

/**
	the Options Menu, used for managing game options
**/
class OptionsMenu extends BaseMenu {
	var categoryList:Array<String> = ['preferences', 'miscellaneous', 'visuals', 'keybinds', 'notes'];

	public function openFromSelection(selectedItem:String):Void {
		switch (selectedItem) {
			case "preferences":
				openSubState(new feather.options.Lists.Preferences());
			case "miscellaneous":
				openSubState(new feather.options.Lists.Miscellaneous());
			case "visuals":
				openSubState(new feather.options.Lists.Visuals());
			case "keybinds":
				openSubState(new funkin.substates.KeybindsSubstate());
			case "notes":
				openSubState(new funkin.states.editors.NoteEditor());
		}
	}

	var fromPlayState:Bool = false;

	public function new(fromPlayState:Bool = false):Void {
		super();

		this.fromPlayState = fromPlayState;
	}

	override function create():Void {
		super.create();

		DiscordRPC.update("OPTIONS MENU", "Setting things up");

		FeatherUtils.menuMusicCheck(false);

		itemContainer = generateOptions();
		add(itemContainer);
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		updateSelection(Controls.isJustPressed("up") ? -1 : Controls.isJustPressed("down") ? 1 : 0);

		if (Controls.isJustPressed("accept")) {
			openFromSelection(itemContainer.members[Math.floor(selection)].text);
		}

		if (Controls.isJustPressed("back")) {
			if (fromPlayState)
				MusicState.switchState(new funkin.states.PlayState());
			else
				MusicState.switchState(new funkin.states.menus.MainMenu());
			FSound.playSound("cancelMenu", 'sounds/menus');
		}
	}

	public override function updateSelection(newSelection:Int = 0):Void {
		super.updateSelection(newSelection);

		if (newSelection != 0)
			FSound.playSound("scrollMenu", 'sounds/menus');
	}

	public function generateOptions():FlxTypedGroup<Alphabet> {
		bgImage = 'menuBGBlue';

		if (itemContainer != null) {
			itemContainer.clear();
			itemContainer.kill();
			remove(itemContainer);
		}

		var tempContainer:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();

		for (i in 0...categoryList.length) {
			var optionTxt:Alphabet = new Alphabet(0, 0, categoryList[i], false);
			optionTxt.screenCenter();
			optionTxt.y += (125 * (i - Math.floor(categoryList.length / 2)));

			optionTxt.targetY = i;
			optionTxt.disableX = true;
			optionTxt.alpha = 0.6;

			tempContainer.add(optionTxt);
		}

		wrappableGroup = categoryList;
		return tempContainer;
	}
}
