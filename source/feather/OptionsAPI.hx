package feather;

import flixel.FlxG;

enum OptionType
{
	CHECKMARK;
	SELECTOR;
	DYNAMIC;
}

enum OptionAttribute
{
	DEFAULT;
	UNCHANGEABLE; // always force an option on it's default value
	UNSELECTABLE;
}

typedef OptionData =
{
	var name:String;
	var ?value:Dynamic;
	var ?values:Array<Dynamic>;
	var ?description:String;
	var ?type:OptionType; // defaults to DYNAMIC if null
	var ?attributes:Array<OptionAttribute>;
}

/**
 * a Class that stores every game setting, along with functions to control game settings
**/
class OptionsAPI
{
	/**
		this is our preferences list, it stores `category` names along with their contents

		for information on how you can create options and customize their behavior
		go to this link => https://github.com/BeastlyGhost/FNF-Funkin-Feather/wiki/Source-Code-Guide#options-documentation
	**/
	public static var preferencesList:Map<String, Array<OptionData>> = [
		/**
			Main Categories
		**/
		"master" => [
			{name: "preferences", type: DYNAMIC},
			{name: "accessibility", type: DYNAMIC},
			{name: "debugging", type: DYNAMIC},
			// {name: "custom settings", type: DYNAMIC},
			{name: "keybinds", type: DYNAMIC}
		],
		/**
			Category Contents
		**/
		"preferences" => [
			{
				name: "Downscroll",
				description: "If the notes should come from top to bottom.",
				type: CHECKMARK,
				value: false
			},
			{
				name: "Ghost Tapping",
				description: "If you should be able to spam when there's no notes to hit during gameplay.",
				type: CHECKMARK,
				value: true
			},
			{
				name: "Center Notes",
				description: "If the notes should be centered.",
				type: CHECKMARK,
				value: false
			},
			{
				name: "Hide Opponent Notes",
				description: "If the Opponent's Notes should be hidden during gameplay.",
				type: CHECKMARK,
				value: false
			},
			{
				name: "Safe Frames",
				description: "Specify the amount of frames you have for hitting notes early / late.",
				type: SELECTOR,
				value: 10
			},
			{
				name: "Note Splash Opacity",
				description: "Set the opacity for your Note Splashes, shown when hitting \"Sick!\" Ratings on Notes.",
				type: SELECTOR,
				value: 60
			},
			{
				name: "User Interface Style",
				description: "Choose your UI Style.",
				type: SELECTOR,
				value: "Feather",
				values: ["Vanilla", "Feather"]
			},
			/*
				{
					name: "Note Quantization",
					description: "If notes should change colors depending on the song beat.",
					type: CHECKMARK,
					value: false
				},
			 */
			{
				name: "Show Info Card",
				description: "If the card with the Song Name and author should be shown when the song begins.",
				type: CHECKMARK,
				value: true
			}
		],
		"accessibility" => [
			{
				name: "Auto Pause",
				description: "If the game should pause itself when the window is unfocused.",
				type: CHECKMARK,
				value: true
			},
			{
				name: "Anti Aliasing",
				description: "If sprite antialiasing should be disabled, may improve performance.",
				type: CHECKMARK,
				value: true
			},
			{
				name: "Flashing Lights",
				description: "If menus and songs should have Flashing Effects.",
				type: CHECKMARK,
				value: true
			},
			{
				name: "Reduce Motion",
				description: "If moving fields like icons and/or Camera Zooms should be reduced/stopped completely.",
				type: CHECKMARK,
				value: false
			},
			{
				name: "Score Bopping",
				description: "If the Score Text on the UI should bounce when you hit notes.",
				type: CHECKMARK,
				value: true,
			}
		],
		"debugging" => [
			{
				name: "Framerate Cap",
				description: "Set your desired FPS limit.",
				type: SELECTOR,
				value: 60
			},
			{
				name: "Show FPS Info",
				description: "If the current framerate should be shown on the Info Counter.",
				type: CHECKMARK,
				value: true
			},
			{
				name: "Accurate FPS Info",
				description: "If the current framerate should be shown accurately.",
				type: CHECKMARK,
				value: false
			},
			{
				name: "Show RAM Info",
				description: "If the current memory usage should be shown on the Info Counter.",
				type: CHECKMARK,
				value: true
			},
			{
				name: "Show Debug Info",
				description: "If the current state folder location and object count should be shown on the Info Counter.",
				type: CHECKMARK,
				value: false
			}
		],
		"custom settings" => [{name: "NOTHING", type: DYNAMIC}],
	];

	public static var myPreferences:Map<String, Array<OptionData>> = [];

	/**
		[Saves your game preferences]
	**/
	public static function savePrefs():Void
	{
		bindSave("Feather-Settings");
		if (myPreferences != null)
			FlxG.save.data.globalSettings = myPreferences;
		// FlxG.save.data.flush();
	}

	/**
		[Loads your game preferences]
	**/
	public static function loadPrefs():Void
	{
		bindSave("Feather-Settings");

		// reset your preferences to the defaults
		for (key => keys in preferencesList)
		{
			if (key != "master" && key != "custom settings")
				myPreferences.set(key, keys);
		}

		if (FlxG.save.data.globalSettings != null)
		{
			// grab from your save file
			var savedPreferences:Map<String, Array<OptionData>> = FlxG.save.data.globalSettings;
			for (saveKey in savedPreferences.keys())
			{
				// this checks if the key exists on the DEFAULT preferences list
				// if it does, then it sets your preferences to the save keys
				// that way saves won't have to be deleted if preferences change overtime
				if (preferencesList.get(saveKey) != null)
					myPreferences.set(saveKey, savedPreferences.get(saveKey));
			}
		}
		else
			FlxG.save.data.globalSettings = new Map<String, Array<OptionData>>();

		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;
		if (FlxG.save.data.seenSplash != null)
			Main.game.skipSplash = FlxG.save.data.seenSplash;

		updatePrefs();
	}

	/**
		[Returns the specified preference from within the preferences map]
		@param name the `name` of your desired preference
		@param getValue if the option `value` should be returned instead of the option itself
		@return your preference, or the default value for it
	**/
	public static function getPref(name:String, getValue:Bool = true):Dynamic
	{
		bindSave("Feather-Settings");

		for (category => contents in preferencesList)
		{
			var chosenMap:Map<String, Array<OptionData>> = [];
			var hasCategory:Bool = (myPreferences != null && myPreferences.exists(category) && myPreferences.get(category) != null);

			chosenMap = (hasCategory ? myPreferences : preferencesList);

			for (i in 0...contents.length)
			{
				if (chosenMap.get(category)[i].name == name)
				{
					var retVal = chosenMap.get(category);
					return (getValue ? retVal[i].value : retVal[i]);
				}
			}
		}

		trace('Preference "$name" does not exist in the preferences map.');
		return null;
	}

	/**
		[Sets a new value to the specified preference from within the preferences map]
		@param name the `name` of your desired preference
		@param newValue the new value for your option
	**/
	public static function setPref(name:String, newValue:Dynamic):Void
	{
		bindSave("Feather-Settings");

		for (category => contents in preferencesList)
		{
			var hasCategory:Bool = (myPreferences.exists(category) && myPreferences.get(category) != null);
			var chosenMap:Map<String, Array<OptionData>> = [];
			chosenMap = (hasCategory ? myPreferences : preferencesList);

			for (i in 0...contents.length)
			{
				if (chosenMap.get(category)[i].name == name)
					chosenMap.get(category)[i].value = newValue;
			}
		}
	}

	/**
		[Updates default game preferences data if needed]
	**/
	public static function updatePrefs():Void
	{
		bindSave("Feather-Settings");

		#if (flixel >= "5.0.0")
		flixel.FlxSprite.defaultAntialiasing = getPref('Anti Aliasing');
		#end

		// to avoid a crash
		var fpsPref:Int = 60;
		if (getPref("Framerate Cap") != null)
			fpsPref = getPref("Framerate Cap");

		FlxG.drawFramerate = FlxG.updateFramerate = fpsPref;
		FlxG.autoPause = getPref('Auto Pause');
	}

	public static function bindSave(name:String):Void
	{
		// FeatherSave.bind(name);
		try
		{
			if (FlxG.save.name != name)
				FlxG.save.bind(name #if (flixel < "5.0.0"), "BeastlyGhost" #end);
		}
		catch (e)
		{
			trace('Unexpected Error when binding save, file name was "$name"');
		}
	}
}
