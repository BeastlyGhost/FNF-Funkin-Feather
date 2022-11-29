package states.menus;

import base.song.MusicState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

/**
	the Main Menu, for now it will remain the same as the base game's,
	do as you wish and customize this to your liking!
**/
class MainMenu extends MusicBeatState
{
	var itemContainer:FlxTypedGroup<FlxSprite>;

	var menuData:Dynamic;

	var menuBG:FlxSprite;
	var menuFlash:FlxSprite;
	var camFollow:FlxObject;

	var lockedMovement:Bool = false;

	override function create()
	{
		super.create();

		menuData = yaml.Yaml.read(AssetHandler.grabAsset("menuData", YAML, "data/menus"));

		DiscordRPC.update("MAIN MENU", "Navigating through the Main Menus");

		FeatherUtils.menuMusicCheck(false);

		wrappableGroup = menuData.get("list");

		persistentUpdate = persistentDraw = true;

		menuBG = new FlxSprite(-80).loadGraphic(AssetHandler.grabAsset(menuData.get("bg"), IMAGE, menuData.get("bgFolder")));
		add(menuBG);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		menuFlash = new FlxSprite(-80).loadGraphic(AssetHandler.grabAsset(menuData.get("flash"), IMAGE, menuData.get("flashFolder")));
		menuFlash.visible = false;
		menuFlash.color = menuData.get("flashColor");
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

		for (i in 0...menuData.get("list").length)
		{
			var item:FlxSprite = new FlxSprite(0, menuData.get("listY") + (i * menuData.get("listSpacing")));
			item.frames = AssetHandler.grabAsset(menuData.get("list")[i], SPARROW, "images/menus/attachements");

			item.animation.addByPrefix('idle', menuData.get("list")[i] + " basic", 24);
			item.animation.addByPrefix('selected', menuData.get("list")[i] + " white", 24);
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
							switch (menuData.get("list")[selection])
							{
								case "story mode":
									PlayState.songName = "bopeebo";
									PlayState.gameplayMode = STORY;
									PlayState.difficulty = 1;
									MusicState.switchState(new PlayState());
								case "freeplay":
									PlayState.songName = "bopeebo";
									PlayState.gameplayMode = FREEPLAY;
									PlayState.difficulty = 1;
									MusicState.switchState(new PlayState());
								case "options":
									PlayState.songName = "bopeebo";
									PlayState.gameplayMode = FREEPLAY;
									PlayState.difficulty = 1;
									MusicState.switchState(new PlayState());
								default:
									MusicState.switchState(new states.TitleState());
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
