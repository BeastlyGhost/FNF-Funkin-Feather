package fnf.states.menus;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import fnf.song.MusicState;

typedef MainMenuForm = {
	var bg:String;
	var flash:String;
	var bgFolder:String;
	var flashFolder:String;
	var flashColor:Int;
	var list:Array<String>;
	var listY:Float;
	var listSpacing:Float;
}

/**
	the Main Menu, for now it will remain the same as the base game's,
	do as you wish and customize this to your liking!
**/
class MainMenu extends MusicBeatState {
	var menuData:MainMenuForm;
	var camFollow:FlxObject;

	public static var instance:MainMenu;

	public var camMain:FlxCamera;
	public var camSub:FlxCamera;

	public static var lockedMovement:Bool = false;
	public static var firstStart:Bool = true;

	public var itemContainer:FlxTypedGroup<FlxSprite>;

	public var menuBG:FlxSprite;
	public var versionText:FlxText;
	public var menuFlash:FlxSprite;

	function resetMenu():Void {
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		menuData = Yaml.read(AssetHelper.grabAsset("mainMenu", YAML, "data/menus"), yaml.Parser.options().useObjects());

		DiscordRPC.update("MAIN MENU", "Navigating through the Main Menus");

		FeatherUtils.menuMusicCheck(firstStart);

		if (firstStart)
			openSubState(new fnf.states.substates.TitleSubstate());
	}

	override function create():Void {
		super.create();

		instance = this;

		resetMenu();

		lockedMovement = firstStart;
		wrappableGroup = menuData.list;

		menuBG = new FlxSprite(-80).loadGraphic(AssetHelper.grabAsset(menuData.bg, IMAGE, menuData.bgFolder));
		add(menuBG);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		menuFlash = new FlxSprite(-80).loadGraphic(AssetHelper.grabAsset(menuData.flash, IMAGE, menuData.flashFolder));
		menuFlash.visible = false;
		menuFlash.color = menuData.flashColor;
		add(menuFlash);

		for (bg in [menuBG, menuFlash]) {
			bg.scrollFactor.set(0, 0.18);
			bg.setGraphicSize(Std.int(bg.width * 1.25));
			bg.updateHitbox();
			bg.screenCenter();
			bg.antialiasing = true;
		}

		itemContainer = new FlxTypedGroup<FlxSprite>();
		add(itemContainer);

		for (i in 0...wrappableGroup.length) {
			var item:FlxSprite = new FlxSprite(0, menuData.listY + (i * menuData.listSpacing));
			item.frames = AssetHelper.grabAsset(wrappableGroup[i], SPARROW, "images/menus/default/items");

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

		versionText = new FlxText(5, FlxG.height - 18, 0, 'Funkin\' Feather ${Main.versionDisplay}', 12);
		versionText.setFormat(AssetHelper.grabAsset("vcr", FONT, "data/fonts"), 16, 0xFFFFFFFF, LEFT, OUTLINE, 0xFF000000);
		versionText.scrollFactor.set();
		add(versionText);

		updateSelection();

		updateObjectAlpha(firstStart ? 0 : 1);
	}

	public function updateObjectAlpha(alphaNew:Float, tweened:Bool = false):Void {
		if (!tweened) {
			itemContainer.forEach(function(spr:FlxSprite) {
				spr.alpha = alphaNew;
			});
			menuBG.alpha = alphaNew;
			versionText.alpha = alphaNew;
		} else {
			itemContainer.forEach(function(spr:FlxSprite) {
				FlxTween.tween(spr, {alpha: alphaNew}, 0.6);
			});
			FlxTween.tween(menuBG, {alpha: alphaNew}, 0.6);
			FlxTween.tween(versionText, {alpha: alphaNew}, 0.6);
		}
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * elapsed;

		if (!lockedMovement) {
			updateSelection(Controls.isJustPressed("up") ? -1 : Controls.isJustPressed("down") ? 1 : 0);

			if (FlxG.keys.justPressed.SEVEN)
				MusicState.switchState(new ModsMenu());

			if (Controls.isJustPressed("back")) {
				persistentUpdate = false;
				openSubState(new fnf.states.substates.WarningSubstate("Are you sure?", "Yes, close the game", "No, not now", function() {
					FlxG.sound.music.fadeOut(0.3);
					FlxG.camera.fade(0xFF000000, 0.5, false, function() {
						Sys.exit(0);
					}, false);
				}));
			}

			if (Controls.isJustPressed("accept")) {
				FSound.playSound("confirmMenu", "sounds/menus");
				lockedMovement = true;

				if (OptionsAPI.getPref("Flashing Lights"))
					FlxFlicker.flicker(menuFlash, 1.1, 0.15, false);

				itemContainer.forEach(function(spr:FlxSprite) {
					if (selection != spr.ID) {
						FlxTween.tween(spr, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween) {
								spr.kill();
							}
						});
					} else {
						FlxFlicker.flicker(spr, 1, 0.1, false, false, function(flick:FlxFlicker) {
							switch (wrappableGroup[Math.floor(selection)].toLowerCase()) {
								case "story mode":
									MusicState.switchState(new StoryMenu());
								case "freeplay":
									MusicState.switchState(new FreeplayMenu());
								case "mods":
									MusicState.switchState(new ModsMenu());
								case "credits":
									MusicState.switchState(new CreditsMenu());
								case "options":
									transIn = FlxTransitionableState.defaultTransIn;
									transOut = FlxTransitionableState.defaultTransOut;
									MusicState.switchState(new OptionsMenu());
								default:
									MusicState.resetState();
							}
						});
					}
				});
			}
		}

		itemContainer.forEach(function(spr:FlxSprite) {
			spr.screenCenter(X);
		});
	}

	override function updateSelection(newSelection:Int = 0):Void {
		super.updateSelection(newSelection);

		if (newSelection != 0)
			FSound.playSound("scrollMenu", 'sounds/menus');

		itemContainer.forEach(function(spr:FlxSprite) {
			spr.animation.play('idle');

			if (spr.ID == selection) {
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
