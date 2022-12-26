package feather.options;

import feather.BaseMenu;
import feather.tools.FeatherUtils;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import funkin.backend.Controls;
import funkin.objects.ui.fonts.Alphabet;
import funkin.objects.ui.menus.OptionThingie;

/**
	Base List for the Options Menu
**/
class BaseList extends BaseSubMenu {
	var myList:Array<String> = ['nothing'];

	var attachedSprites:FlxTypedGroup<FlxBasic>;
	var attachedSpriteMap:Map<Alphabet, Dynamic>;

	var menuCamera:FlxCamera;

	public override function new(newList:Array<String>):Void {
		super();

		myList = newList;
	}

	public override function create():Void {
		super.create();

		bgImage = 'menuDesat';
		menuBG.color = 0xFFEA71FD;

		camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);

		menuCamera = new FlxCamera();
		FlxG.cameras.add(menuCamera, false);
		menuCamera.bgColor = 0x00000000;
		camera = menuCamera;

		menuCamera.follow(camFollow, null, 0.06);
		menuCamera.deadzone.set(0, 160, menuCamera.width, 40);
		menuCamera.minScrollY = 0;

		if (myList.length > 0) {
			itemContainer = generateOptions();
			add(itemContainer);

			callAttachments();
		}

		updateSelection();

		// cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		menuCamera.followLerp = FeatherUtils.cameraLerping(0.05);

		itemContainer.forEach(function(item:Alphabet) {
			var selected:Bool = (item == itemContainer.members[Math.floor(selection)]);
			item.x = selected ? 150 : 120;
		});

		if (attachedSprites != null)
			moveAttachedSprites();

		/**
			CONTROLS
		**/

		updateSelection(Controls.isJustPressed("up") ? -1 : Controls.isJustPressed("down") ? 1 : 0);

		updateOption();

		if (Controls.isJustPressed("back"))
			close();
	}

	public override function updateSelection(newSelection:Int = 0):Void {
		super.updateSelection(newSelection);

		if (itemContainer.members.length > 8) {
			var item:Alphabet = itemContainer.members[Math.floor(selection)];
			camFollow.y = item.y;
		}

		if (newSelection != 0)
			FSound.playSound("scrollMenu", 'sounds/menus');
	}

	public function generateOptions():FlxTypedGroup<Alphabet> {
		if (itemContainer != null) {
			itemContainer.clear();
			itemContainer.kill();
			remove(itemContainer);
		}

		var tempContainer:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();

		for (i in 0...myList.length) {
			var optionTxt:Alphabet = new Alphabet(0, 0, myList[i], false);

			optionTxt.screenCenter();
			optionTxt.y += (105 * (i - Math.floor(myList.length / 2)));

			optionTxt.targetY = i;
			optionTxt.disableX = true;
			optionTxt.alpha = 0.6;

			tempContainer.add(optionTxt);
		}

		wrappableGroup = myList;

		return tempContainer;
	}

	public function generateAttachments(parent:FlxTypedGroup<Alphabet>):Map<Alphabet, Dynamic> {
		var mapFinal:Map<Alphabet, Dynamic> = new Map<Alphabet, Dynamic>();

		for (option in parent) {
			if (option != null && OptionsAPI.getPref(option.text, false) != null) {
				// trace("OPTION IS NOT NULL, CONTINUING....");

				var curVal:Any = OptionsAPI.getPref(option.text);

				if (curVal != null) {
					// set option types based on the default value
					if (curVal is Bool) {
						var box:CheckboxThingie = new CheckboxThingie(10, option.y);
						box.parentSprite = option;
						box.scrollFactor.set();

						// true is false????
						box.playAnim(Std.string(!OptionsAPI.getPref(option.text)));
						mapFinal.set(option, box);
					}

					if (curVal is Int || curVal is Float || curVal is Array) {
						var values:Array<String> = OptionsAPI.preferences.get(option.text)[1];
						var arrow:SelectorThingie = new SelectorThingie(10, option.y, option.text, values);
						mapFinal.set(option, arrow);
					}
				}
			}
		}

		return mapFinal;
	}

	public function updateOption():Void {
		var item:Alphabet = itemContainer.members[Math.floor(selection)];

		if (item == null)
			return;

		var type:Any = OptionsAPI.getPref(item.text);

		if (type is Bool) {
			if (Controls.isJustPressed("accept")) {
				var value = OptionsAPI.getPref(item.text);
				OptionsAPI.setPref(item.text, !value);
				attachedSpriteMap.get(item).playAnim(Std.string(value));
				OptionsAPI.savePrefs();
			}
		}

		if (type is Int || type is Float || type is Array) {
			var selector:SelectorThingie = attachedSpriteMap.get(item);

			var amount:Int = (Controls.isJustPressed("left") ? -1 : Controls.isJustPressed("right") ? 1 : 0);

			switch (selector.name) {
				case "Framerate Cap":
					createSelector(amount, selector, 30, 360, 15);
				case "Safe Frames":
					createSelector(amount, selector, 1, 10);
				default:
					createSelector(amount, selector);
			}
		}

		OptionsAPI.updatePrefs();
	}

	function createSelector(amount:Int, selector:SelectorThingie, min:Float = 0, max:Float = 100, inc:Float = 5):Void {
		if (selector.number) {
			var value = OptionsAPI.getPref(selector.name);
			var increase = 15 * amount;

			increase = FlxMath.wrap(value + increase, Std.int(min), Std.int(max));
			value += increase;

			manageSelector(selector, value, amount);
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

	function manageSelector(object:SelectorThingie, value:Any, steps:Int):Void {
		if (steps != 0) {
			object.choice = value;
			FSound.playSound("scrollMenu", 'sounds/menus');
		}

		OptionsAPI.setPref(object.name, value);
		OptionsAPI.savePrefs();
	}

	function callAttachments():Void {
		if (attachedSprites != null)
			remove(attachedSprites);

		if (attachedSpriteMap != null)
			attachedSpriteMap = [];

		if (itemContainer == null || itemContainer.members == null)
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
}
