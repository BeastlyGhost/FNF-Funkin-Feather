package funkin.states.menus;

import feather.BaseMenu;
import feather.OptionsAPI;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import funkin.essentials.song.MusicState;
import funkin.objects.ui.fonts.Alphabet;
import funkin.objects.ui.menus.OptionThingie;

/**
	the Options Menu, used for managing game options
**/
class OptionsMenu extends BaseMenu {
	var attachedSprites:FlxTypedGroup<FlxBasic>;
	var attachedSpriteMap:Map<Alphabet, Dynamic>;

	var activeCategory:String = 'master';

	var fromPlayState:Bool = false;

	var menuCamera:FlxCamera;

	public function new(fromPlayState:Bool = false):Void {
		super();

		this.fromPlayState = fromPlayState;
	}

	override function create():Void {
		super.create();

		DiscordRPC.update("OPTIONS MENU", "Setting things up");

		FeatherUtils.menuMusicCheck(false);

		camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);

		menuCamera = new FlxCamera();
		FlxG.cameras.add(menuCamera, false);
		menuCamera.bgColor = FlxColor.TRANSPARENT;
		camera = menuCamera;

		menuCamera.follow(camFollow, null, 0.06);
		menuCamera.deadzone.set(0, 160, menuCamera.width, 40);
		menuCamera.minScrollY = 0;

		switchCategory("master");
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		menuCamera.followLerp = FeatherUtils.cameraLerping(0.05);
		if (activeCategory != 'master') {
			itemContainer.forEach(function(item:Alphabet) {
				var selected:Bool = (item == itemContainer.members[Math.floor(selection)]);
				item.x = (selected ? 150 : 120);
			});
		}

		if (attachedSprites != null)
			moveAttachedSprites();

		if (wrappableGroup != null) {
			for (i in 0...wrappableGroup.length) {
				if (wrappableGroup[i].attributes != null && wrappableGroup[i].attributes.contains(UNSELECTABLE))
					itemContainer.members[i].alpha = 0.6;
			}
		}

		updateSelection(Controls.isJustPressed("up") ? -1 : Controls.isJustPressed("down") ? 1 : 0);

		/**
			this part sucks
			will change it later
			@BeastlyGhost
		**/

		var accept:Bool = Controls.isJustPressed("accept");

		var left:Bool = Controls.isJustPressed("left");
		var right:Bool = Controls.isJustPressed("right");

		if (accept || (left || right)) {
			var isDynamic:Bool = (wrappableGroup[Math.floor(selection)].type == DYNAMIC);
			var isOption:Bool = (wrappableGroup[Math.floor(selection)].attributes != null
				&& wrappableGroup[Math.floor(selection)].attributes.contains(DEFAULT));

			if (!isDynamic && isOption)
				updateOption(wrappableGroup[Math.floor(selection)].type);

			if (accept) {
				if (isDynamic) {
					if (wrappableGroup[Math.floor(selection)].name == "keybinds")
						openSubState(new funkin.substates.KeybindsSubstate(true));
					else
						switchCategory(wrappableGroup[Math.floor(selection)].name);
				}
			}
		}

		if (Controls.isJustPressed("back")) {
			if (activeCategory != 'master')
				switchCategory('master');
			else {
				if (fromPlayState)
					MusicState.switchState(new funkin.states.PlayState());
				else
					MusicState.switchState(new funkin.states.menus.MainMenu());
			}

			FSound.playSound("cancelMenu", 'sounds/menus');
		}
	}

	public override function updateSelection(newSelection:Int = 0):Void {
		super.updateSelection(newSelection);

		var selectionJumper:Int = (newSelection > selection ? 1 : (newSelection < selection) ? -1 : 0);

		if (newSelection != 0)
			FSound.playSound("scrollMenu", 'sounds/menus');

		if (itemContainer.members.length > 5) {
			var item:Alphabet = itemContainer.members[Math.floor(selection)];
			camFollow.y = (activeCategory == 'master' ? 0 : item.y);
		}

		if (wrappableGroup[Math.floor(selection)].attributes != null
			&& wrappableGroup[Math.floor(selection)].attributes.contains(UNSELECTABLE))
			updateSelection(Math.floor(selection) + selectionJumper);
	}

	public function callAttachments():Void {
		if (attachedSprites != null)
			remove(attachedSprites);

		if (attachedSpriteMap != null)
			attachedSpriteMap = [];

		if (itemContainer == null || itemContainer.members == null || activeCategory == 'master')
			return;

		attachedSpriteMap = generateAttachments(itemContainer);
		attachedSprites = new FlxTypedGroup<FlxBasic>();
		for (s in itemContainer)
			if (attachedSpriteMap.get(s) != null)
				attachedSprites.add(attachedSpriteMap.get(s));
		add(attachedSprites);

		moveAttachedSprites();
	}

	function moveAttachedSprites():Void {
		// move the attachments if there are any
		for (setting in attachedSpriteMap.keys()) {
			if ((setting != null) && (attachedSpriteMap.get(setting) != null)) {
				var thisAttachment = attachedSpriteMap.get(setting);
				thisAttachment.x = setting.x - 100;
				thisAttachment.y = setting.y - 50;
			}
		}
	}

	public function switchCategory(newCategory:String):Void {
		if (!OptionsAPI.preferencesList.exists(newCategory))
			return;

		activeCategory = newCategory;

		itemContainer = generateOptions(OptionsAPI.preferencesList.get(newCategory));
		add(itemContainer);

		callAttachments();

		selection = 0;
		updateSelection(Math.floor(selection));
	}

	public function generateOptions(optionsArray:Array<OptionForm>):FlxTypedGroup<Alphabet> {
		bgImage = (activeCategory == 'master' ? 'menuBGBlue' : 'menuDesat');
		if (bgImage == 'menuDesat')
			menuBG.color = 0xFFEA71FD;

		if (itemContainer != null) {
			itemContainer.clear();
			itemContainer.kill();
			remove(itemContainer);
		}

		var tempContainer:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();

		for (i in 0...optionsArray.length) {
			var option:OptionForm = optionsArray[i];

			// set to default value
			if (option.type == null)
				option.type = DYNAMIC;

			if (option.attributes == null)
				option.attributes = [DEFAULT];
			// we do this to avoid crashes with options that have no attributes @BeastlyGhost

			if (!option.attributes.contains(UNCHANGEABLE)) {
				var optionTxt:Alphabet = new Alphabet(0, 0, option.name, false);

				// find unselectable options for automatically centering them
				if (option.attributes.contains(UNSELECTABLE)) {
					optionTxt.screenCenter(X);
					optionTxt.forceX = optionTxt.x;
					optionTxt.displacement.x = 100;
					optionTxt.displacement.y = -55;
				} else {
					optionTxt.screenCenter();
					optionTxt.y += (125 * (i - Math.floor(optionsArray.length / 2)));
				}

				optionTxt.targetY = i;
				optionTxt.disableX = true;
				optionTxt.alpha = 0.6;

				tempContainer.add(optionTxt);
			}
		}

		wrappableGroup = optionsArray;
		return tempContainer;
	}

	public function generateAttachments(parent:FlxTypedGroup<Alphabet>):Map<Alphabet, Dynamic> {
		var mapFinal:Map<Alphabet, Dynamic> = new Map<Alphabet, Dynamic>();

		if (activeCategory == 'master')
			return mapFinal;

		for (option in parent) {
			if (option != null && OptionsAPI.getPref(option.text, false) != null) {
				// trace("OPTION IS NOT NULL, CONTINUING....");

				if (OptionsAPI.getPref(option.text, false).type != null) {
					switch (OptionsAPI.getPref(option.text, false).type) {
						case CHECKMARK:
							var box:CheckboxThingie = new CheckboxThingie(10, option.y);
							box.parentSprite = option;
							box.scrollFactor.set();

							// true is false????
							box.playAnim(Std.string(!OptionsAPI.getPref(option.text)));
							mapFinal.set(option, box);
						case SELECTOR:
							var values:Array<String> = OptionsAPI.getPref(option.text, false).values;

							var arrow:SelectorThingie = new SelectorThingie(10, option.y, option.text, values);
							mapFinal.set(option, arrow);
						default:
							//
					}
				}
			}
		}

		return mapFinal;
	}

	public function updateOption(type:OptionType):Void {
		var item:Alphabet = itemContainer.members[Math.floor(selection)];

		if (item == null)
			return;

		switch (type) {
			case CHECKMARK:
				if (Controls.isJustPressed("accept")) {
					var value = OptionsAPI.getPref(item.text);
					OptionsAPI.setPref(item.text, !value);
					attachedSpriteMap.get(item).playAnim(Std.string(value));
					OptionsAPI.savePrefs();
				}
			case SELECTOR:
				if (Controls.isJustPressed("left") || Controls.isJustPressed("right")) {
					var selector:SelectorThingie = attachedSpriteMap.get(item);
					var amount:Int = (Controls.isJustPressed("left") ? -1 : Controls.isJustPressed("right") ? 1 : 0);

					updateHorizontal(selector, amount);
				}
			default:
				// do nothing
		}

		OptionsAPI.updatePrefs();
	}

	private function updateHorizontal(selector:SelectorThingie, amount:Int):Void {
		if (selector.number) {
			switch (selector.name) {
				case "Framerate Cap":
					createNumberSelector(amount, selector, 30, 360, 15);
				default:
					createNumberSelector(amount, selector);
			}
		} else {
			var choiceSel:Int = 0, selLimiter:Int = 0;
			if (selector.ops != null) {
				for (i in 0...selector.ops.length)
					if (selector.ops[i] == selector.choice)
						choiceSel = i;

				selLimiter = FlxMath.wrap(choiceSel + amount, 0, selector.ops.length - 1);
				manageSelector(selector, selector.ops[selLimiter], amount);
			}
		}
	}

	private function createNumberSelector(steps:Int, object:SelectorThingie, min:Float = 0, max:Float = 100, inc:Float = 5):Void {
		// lazily hardcoded selector generator.
		var originalValue = OptionsAPI.getPref(object.name);
		var increase = 15 * steps;

		increase = FlxMath.wrap(originalValue + increase, Std.int(min), Std.int(max));
		originalValue += increase;

		manageSelector(object, originalValue, steps);
	}

	function manageSelector(object:SelectorThingie, value:Any, steps:Int):Void {
		object.choice = Std.string(value);
		object.changeArrow(steps == -1 ? false : true);

		FSound.playSound("scrollMenu", 'sounds/menus');

		trace("Value is: " + object.choice);

		if (object.choice != null) {
			OptionsAPI.setPref(object.name, value);
			OptionsAPI.savePrefs();
		}
	}
}
