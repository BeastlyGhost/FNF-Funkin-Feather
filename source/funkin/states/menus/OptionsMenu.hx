package funkin.states.menus;

import feather.BaseMenu;
import feather.OptionsAPI;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import funkin.objects.ui.fonts.Alphabet;
import funkin.objects.ui.menus.OptionThingie;
import funkin.essentials.song.MusicState;

/**
	the Options Menu, used for managing game options
**/
class OptionsMenu extends BaseMenu
{
	var attachedSprites:FlxTypedGroup<FlxBasic>;
	var attachedSpriteMap:Map<Alphabet, Dynamic>;

	var activeCategory:String = 'master';

	var fromPlayState:Bool = false;

	public function new(fromPlayState:Bool = false):Void
	{
		super();

		this.fromPlayState = fromPlayState;
	}

	override function create():Void
	{
		super.create();

		bgImage = 'menuBGBlue';

		DiscordRPC.update("OPTIONS MENU", "Setting things up");

		FeatherTools.menuMusicCheck(false);

		switchCategory("master");
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (attachedSprites != null)
			moveAttachedSprites();

		if (wrappableGroup != null)
		{
			for (i in 0...wrappableGroup.length)
			{
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

		if (accept || (left || right))
		{
			var isDynamic:Bool = (wrappableGroup[selection].type == DYNAMIC);
			var isOption:Bool = (wrappableGroup[selection].attributes != null && wrappableGroup[selection].attributes.contains(DEFAULT));

			if (!isDynamic && isOption)
				updateOption(wrappableGroup[selection].type);

			if (accept)
			{
				if (isDynamic)
				{
					if (wrappableGroup[selection].name == "keybinds")
						openSubState(new funkin.substates.KeybindsSubstate(true));
					else
						switchCategory(wrappableGroup[selection].name);
				}
			}
		}

		if (Controls.isJustPressed("back"))
		{
			if (activeCategory != 'master')
				switchCategory('master');
			else
			{
				if (fromPlayState)
					MusicState.switchState(new funkin.states.PlayState());
				else
					MusicState.switchState(new funkin.states.menus.MainMenu());
			}

			FSound.playSound("cancelMenu", 'sounds/menus');
		}
	}

	override public function updateSelection(newSelection:Int = 0):Void
	{
		super.updateSelection(newSelection);

		var selectionJumper:Int = ((newSelection > selection) ? 1 : -1);

		if (newSelection != 0)
			FSound.playSound("scrollMenu", 'sounds/menus');

		// doesn't quite work yet, eeeh
		// if (wrappableGroup[selection].attributes != null && wrappableGroup[selection].attributes.contains(UNSELECTABLE))
		// 	updateSelection(selection + selectionJumper);
	}

	public function callAttachments():Void
	{
		if (attachedSprites != null)
			remove(attachedSprites);

		if (attachedSpriteMap != null)
			attachedSpriteMap = [];

		attachedSpriteMap = generateAttachments(itemContainer);
		attachedSprites = new FlxTypedGroup<FlxBasic>();
		for (s in itemContainer)
			if (attachedSpriteMap.get(s) != null)
				attachedSprites.add(attachedSpriteMap.get(s));
		add(attachedSprites);

		moveAttachedSprites();
	}

	function moveAttachedSprites():Void
	{
		// move the attachments if there are any
		for (setting in attachedSpriteMap.keys())
		{
			if ((setting != null) && (attachedSpriteMap.get(setting) != null))
			{
				var thisAttachment = attachedSpriteMap.get(setting);
				thisAttachment.x = setting.x - 100;
				thisAttachment.y = setting.y - 50;
			}
		}
	}

	public function switchCategory(newCategory:String):Void
	{
		if (!OptionsAPI.preferencesList.exists(newCategory))
			return;

		activeCategory = newCategory;

		generateOptions(OptionsAPI.preferencesList.get(newCategory));

		selection = 0;
		updateSelection(selection);
	}

	public function generateOptions(optionsArray:Array<OptionData>):Void
	{
		if (itemContainer != null)
		{
			itemContainer.clear();
			itemContainer.kill();
			remove(itemContainer);
		}

		itemContainer = new FlxTypedGroup<Alphabet>();

		for (i in 0...optionsArray.length)
		{
			var option:OptionData = optionsArray[i];

			// set to default value
			if (option.type == null)
				option.type = DYNAMIC;

			if (option.attributes == null)
				option.attributes = [DEFAULT];
			// we do this to avoid crashes with options that have no attributes @BeastlyGhost

			if (!option.attributes.contains(UNCHANGEABLE))
			{
				var optionTxt:Alphabet = new Alphabet(0, 0, option.name, false);

				// find unselectable options for automatically centering them
				if (option.attributes.contains(UNSELECTABLE))
				{
					optionTxt.screenCenter(X);
					optionTxt.forceX = optionTxt.x;
					optionTxt.displacement.y = -55;
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

		callAttachments();

		wrappableGroup = optionsArray;
	}

	public function generateAttachments(parent:FlxTypedGroup<Alphabet>):Map<Alphabet, Dynamic>
	{
		var mapFinal:Map<Alphabet, Dynamic> = new Map<Alphabet, Dynamic>();

		if (activeCategory == 'master')
			return mapFinal;

		for (option in parent)
		{
			if (option != null && OptionsAPI.getPref(option.text, false) != null)
			{
				// trace("OPTION IS NOT NULL, CONTINUING....");

				if (OptionsAPI.getPref(option.text, false).type != null)
				{
					switch (OptionsAPI.getPref(option.text, false).type)
					{
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
							arrow.scrollFactor.set();
							mapFinal.set(option, arrow);
						default:
							//
					}
				}
			}
		}

		return mapFinal;
	}

	public function updateOption(type:OptionType):Void
	{
		var item:Alphabet = itemContainer.members[selection];

		if (item == null)
			return;

		switch (type)
		{
			case CHECKMARK:
				if (Controls.isJustPressed("accept"))
				{
					var value = OptionsAPI.getPref(item.text);
					OptionsAPI.setPref(item.text, !value);
					attachedSpriteMap.get(item).playAnim(Std.string(value));
					OptionsAPI.savePrefs();
				}
			case SELECTOR:
				if (Controls.isJustPressed("left") || Controls.isJustPressed("right"))
				{
					var selector:SelectorThingie = attachedSpriteMap.get(item);
					var amount:Int = (Controls.isJustPressed("left") ? -1 : Controls.isJustPressed("right") ? 1 : 0);

					updateHorizontal(selector, amount);
				}
			default:
				// do nothing
		}

		OptionsAPI.updatePrefs();
	}

	private function updateHorizontal(selector:SelectorThingie, amount:Int):Void
	{
		if (selector.number)
		{
			switch (selector.name)
			{
				case "Framerate Cap":
					createNumberSelector(amount, selector, 30, 360, 15);
				default:
					createNumberSelector(amount, selector);
			}
		}
		else
		{
			var choiceSel:Int = 0, selLimiter:Int = 0;
			if (selector.ops != null)
			{
				for (i in 0...selector.ops.length)
					if (selector.ops[i] == selector.choice)
						choiceSel = i;

				selLimiter = FlxMath.wrap(choiceSel + amount, 0, selector.ops.length - 1);
				manageSelector(selector, selector.ops[selLimiter], amount);
			}
		}
	}

	private function createNumberSelector(steps:Int, object:SelectorThingie, min:Float = 0, max:Float = 100, inc:Float = 5):Void
	{
		// lazily hardcoded selector generator.
		var originalValue = OptionsAPI.getPref(object.name);
		var increase = 15 * steps;

		increase = FlxMath.wrap(originalValue + increase, Std.int(min), Std.int(max));
		originalValue += increase;

		manageSelector(object, originalValue, steps);
	}

	function manageSelector(object:SelectorThingie, value:Any, steps:Int):Void
	{
		object.choice = Std.string(value);
		object.changeArrow(steps == -1 ? false : true);

		FSound.playSound("scrollMenu", 'sounds/menus');

		trace("Value is: " + object.choice);

		if (object.choice != null)
		{
			OptionsAPI.setPref(object.name, value);
			OptionsAPI.savePrefs();
		}
	}
}
