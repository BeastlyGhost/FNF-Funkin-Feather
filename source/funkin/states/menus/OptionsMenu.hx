package funkin.states.menus;

import base.meta.OptionsMeta;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.data.OptionsContainer;
import funkin.objects.ui.Alphabet;
import funkin.song.MusicState;

/**
	the Options Menu, used for managing game options
**/
class OptionsMenu extends MusicBeatState
{
	var itemContainer:FlxTypedGroup<Alphabet>;
	var categories:Map<String, Array<OptionData>> = [
		"master" => [
			{name: "gameplay", type: DYNAMIC},
			{name: "accessibility", type: DYNAMIC},
			{name: "debugging", type: DYNAMIC},
			{name: "custom settings", type: DYNAMIC},
			{name: "keybinds", type: DYNAMIC},
		],
	];

	var activeContainer:Array<OptionData> = [];

	var activeCategory:String = 'master';

	var menuBG:FlxSprite;

	override function create()
	{
		super.create();

		DiscordRPC.update("OPTIONS MENU", "Setting things up");

		menuBG = new FlxSprite(-80).loadGraphic(AssetHandler.grabAsset('menuBGBlue', IMAGE, 'images/menus'));
		menuBG.scrollFactor.set();
		menuBG.screenCenter(X);
		add(menuBG);

		switchCategory("master");
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (activeContainer != null)
		{
			for (i in 0...activeContainer.length)
			{
				if (activeContainer[i].attributes != null && activeContainer[i].attributes.contains(UNSELECTABLE))
					itemContainer.members[i].alpha = 0.6;
			}
		}

		if (Controls.getPressEvent("ui_up"))
			updateSelection(-1);
		if (Controls.getPressEvent("ui_down"))
			updateSelection(1);

		if (Controls.getPressEvent("accept")) {}
		if (Controls.getPressEvent("back"))
			MusicState.switchState(new MainMenu());
	}

	override public function updateSelection(newSelection:Int = 0)
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

		if (activeContainer[selection].attributes != null && activeContainer[selection].attributes.contains(UNSELECTABLE))
			updateSelection(selection + selectionJumper);
	}

	public function switchCategory(newCategory:String)
	{
		activeCategory = newCategory;

		generateOptions(categories.get(newCategory));

		selection = 0;
		updateSelection(selection);
	}

	public function generateOptions(optionsArray:Array<OptionData>)
	{
		activeContainer = optionsArray;

		if (itemContainer != null)
		{
			itemContainer.clear();
			itemContainer.kill();
			remove(itemContainer);
		}

		itemContainer = new FlxTypedGroup<Alphabet>();

		for (i in 0...optionsArray.length)
		{
			var option = optionsArray[i];

			// set to default value
			if (option.attributes == null)
				option.attributes = [NOT_FORCED];
			// we do this to avoid crashes with options that have no attributes @BeastlyGhost

			if (!option.attributes.contains(FORCED))
			{
				var optionTxt:Alphabet = new Alphabet(0, 0, option.name, true);

				// find unselectable options for automatically centering them
				if (option.attributes.contains(UNSELECTABLE))
				{
					optionTxt.screenCenter(X);
					optionTxt.forceX = optionTxt.x;
					optionTxt.yAdd = -55;
					optionTxt.scrollFactor.set();
				}
				else
				{
					optionTxt.screenCenter();
					optionTxt.y += (125 * (i - Math.floor(optionsArray.length / 2)));
				}

				optionTxt.targetY = i;
				optionTxt.disableX = true;
				if (activeCategory != 'master')
					optionTxt.isMenuItem = true;
				optionTxt.alpha = 0.6;
				itemContainer.add(optionTxt);
			}
		}

		add(itemContainer);

		wrappableGroup = activeContainer;
	}
}
