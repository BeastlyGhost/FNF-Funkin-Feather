package funkin.states.menus;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.data.MenuData.MainMenuData;
import funkin.song.MusicState;

/**
	the Main Menu, for now it will remain the same as the base game's,
	do as you wish and customize this to your liking!
**/
class MainMenu extends MusicBeatState
{
	var itemContainer:FlxTypedGroup<FlxSprite>;

	var menuData:MainMenuData;

	var menuBG:FlxSprite;
	var menuFlash:FlxSprite;
	var camFollow:FlxObject;

	var lockedMovement:Bool = false;

	override function create()
	{
		super.create();

		menuData = Yaml.read(AssetHandler.grabAsset("menuData", YAML, "data/menus"), yaml.Parser.options().useObjects());

		DiscordRPC.update("MAIN MENU", "Navigating through the Main Menus");

		FeatherTools.menuMusicCheck(false);

		wrappableGroup = menuData.list;

		persistentUpdate = persistentDraw = true;

		menuBG = new FlxSprite(-80).loadGraphic(AssetHandler.grabAsset(menuData.bg, IMAGE, menuData.bgFolder));
		add(menuBG);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		menuFlash = new FlxSprite(-80).loadGraphic(AssetHandler.grabAsset(menuData.flash, IMAGE, menuData.flashFolder));
		menuFlash.visible = false;
		menuFlash.color = menuData.flashColor;
		add(menuFlash);

		for (bg in [menuBG, menuFlash])
		{
			bg.scrollFactor.set(0, 0.18);
			bg.setGraphicSize(Std.int(bg.width * 1.1));
			bg.updateHitbox();
			bg.screenCenter();
			bg.antialiasing = true;
		}

		itemContainer = new FlxTypedGroup<FlxSprite>();
		add(itemContainer);

		for (i in 0...wrappableGroup.length)
		{
			var item:FlxSprite = new FlxSprite(0, menuData.listY + (i * menuData.listSpacing));
			item.frames = AssetHandler.grabAsset(wrappableGroup[i], SPARROW, "images/menus/attachements");

			item.animation.addByPrefix('idle', wrappableGroup[i] + " basic", 24);
			item.animation.addByPrefix('selected', wrappableGroup[i] + " white", 24);
			item.animation.play('idle');

			item.ID = i;

			item.screenCenter(X);
			item.scrollFactor.set();
			item.antialiasing = true;

			itemContainer.add(item);
		}

		FlxG.camera.follow(camFollow, null, MusicState.boundFramerate(0.06));

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "Funkin' Feather v" + Main.game.version, 12);
		versionShit.setFormat(AssetHandler.grabAsset("vcr", FONT, "data/fonts"), 16, 0xFFFFFFFF, LEFT, OUTLINE, 0xFF000000);
		versionShit.scrollFactor.set();
		add(versionShit);

		updateSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * elapsed;

		if (!lockedMovement)
		{
			if (Controls.getPressEvent("ui_up"))
				updateSelection(-1);

			if (Controls.getPressEvent("ui_down"))
				updateSelection(1);

			if (Controls.getPressEvent("back"))
				MusicState.switchState(new TitleState());

			if (Controls.getPressEvent("accept"))
			{
				FlxG.sound.play(AssetHandler.grabAsset('confirmMenu', SOUND, "sounds/menus"));
				lockedMovement = true;

				if (OptionsMeta.getPref("Flashing Lights"))
					FlxFlicker.flicker(menuFlash, 1.1, 0.15, false);

				itemContainer.forEach(function(spr:FlxSprite)
				{
					if (selection != spr.ID)
					{
						FlxTween.tween(spr, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					}
					else
					{
						FlxFlicker.flicker(spr, 1, 0.1, false, false, function(flick:FlxFlicker)
						{
							switch (wrappableGroup[selection])
							{
								case "story mode":
									MusicState.switchState(new StoryMenu());
								case "freeplay":
									MusicState.switchState(new FreeplayMenu());
								case "options":
									MusicState.switchState(new OptionsMenu());
								default:
									MusicState.resetState();
							}
						});
					}
				});
			}
		}

		itemContainer.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	override function updateSelection(newSelection:Int = 0)
	{
		super.updateSelection(newSelection);

		if (newSelection != 0)
			FlxG.sound.play(AssetHandler.grabAsset('scrollMenu', SOUND, "sounds/menus"));

		itemContainer.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == selection)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
