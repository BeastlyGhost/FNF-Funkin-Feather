package funkin.states.menus;

import feather.BaseMenu;
import feather.assets.AssetGroup;
import flixel.FlxG;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.essentials.song.MusicState;
import funkin.objects.ui.fonts.Alphabet;

/**
    Mods Menu, contains functions for sorting and enabling/disabling current Mods
    Mods are, simply put, Asset Groups, and they can have special properties from
    within their data file, `group.yaml`

    this menu was made as a way to interact with `group.yaml` in order to make
    sorting through mods and such much easier

    @since INFDEV
**/
class ModsMenu extends BaseMenu
{
    override function create():Void
    {
        super.create();

        DiscordRPC.update("MODS MENU", "Navigating through the Main Menus");

        bgImage = 'menuDesat';
		menuBG.color = 0xFFEA71FD;

        itemContainer = generateOptions();
        add(itemContainer);

        selection = 0;
        updateSelection();
    }

    override function update(elapsed:Float):Void
    {
        updateSelection(Controls.isJustPressed("up") ? -1 : Controls.isJustPressed("down") ? 1 : 0);

        if (Controls.isJustPressed("back"))
            MusicState.switchState(new MainMenu());
    }

    override function updateSelection(newSelection:Int = 0):Void
	{
		super.updateSelection(newSelection);

		if (newSelection != 0)
			FSound.playSound("scrollMenu", "sounds/menus");
	}

    function generateOptions():FlxTypedGroup<Alphabet>
    {
        var tempContainer:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();

        for (i in 0...AssetGroup.allGroups.length)
		{
            var optionTxt:Alphabet = new Alphabet(0, 0, AssetGroup.allGroups[i], false);
            optionTxt.screenCenter();
            optionTxt.y += (125 * (i - Math.floor(AssetGroup.allGroups.length / 2)));
            optionTxt.disableX = true;
            optionTxt.targetY = i;
            optionTxt.alpha = 0.6;

            tempContainer.add(optionTxt);
		}

        wrappableGroup = AssetGroup.allGroups;

        return tempContainer;
    }

    function openManagerSubmenu():Void
    {
        //
    }
}