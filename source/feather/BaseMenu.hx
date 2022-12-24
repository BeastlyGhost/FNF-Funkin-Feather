package feather;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.essentials.song.MusicState;
import funkin.objects.ui.fonts.Alphabet;

class BaseMenu extends MusicBeatState {
	var menuBG:FlxSprite;
	var bgImage(default, set):String;
	var itemContainer:FlxTypedGroup<Alphabet>;

	var camFollow:FlxObject;

	function set_bgImage(newImage:String):String {
		bgImage = newImage;

		if (menuBG != null)
			remove(menuBG);

		if (bgImage != null) {
			menuBG = new FlxSprite(-80).loadGraphic(AssetHelper.grabAsset(bgImage, IMAGE, 'images/menus/default'));
			menuBG.scrollFactor.set();
			menuBG.screenCenter(X);
			add(menuBG);
		}

		return newImage;
	}

	public override function updateSelection(newSelection:Int = 0):Void {
		super.updateSelection(newSelection);

		if (newSelection != 0)
			FSound.playSound("scrollMenu", "sounds/menus");

		if (itemContainer != null && itemContainer.members != null) {
			var blah:Int = 0;
			for (item in itemContainer.members) {
				item.targetY = blah - selection;
				blah++;

				item.alpha = 0.6;
				if (item.targetY == 0)
					item.alpha = 1;
			}
		}
	}
}

class BaseSubMenu extends MusicBeatSubstate {
	var menuBG:FlxSprite;
	var bgImage(default, set):String;
	var itemContainer:FlxTypedGroup<Alphabet>;

	function set_bgImage(newImage:String):String {
		bgImage = newImage;

		if (menuBG != null)
			remove(menuBG);

		if (bgImage != null) {
			menuBG = new FlxSprite(-80).loadGraphic(AssetHelper.grabAsset(bgImage, IMAGE, 'images/menus/default'));
			menuBG.scrollFactor.set();
			menuBG.screenCenter(X);
			add(menuBG);
		}

		return newImage;
	}

	public override function updateSelection(newSelection:Int = 0):Void {
		super.updateSelection(newSelection);

		if (newSelection != 0)
			FSound.playSound("scrollMenu", "sounds/menus");

		if (itemContainer != null && itemContainer.members != null) {
			var blah:Int = 0;
			for (item in itemContainer.members) {
				item.targetY = blah - selection;
				blah++;

				item.alpha = 0.6;
				if (item.targetY == 0)
					item.alpha = 1;
			}
		}
	}
}
