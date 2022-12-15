package feather.apis;

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
		go to this link => 
	**/
	public static var preferencesList:Map<String, Array<OptionData>> = [
		"master" => [
			{name: "preferences", type: DYNAMIC},
			{name: "accessibility", type: DYNAMIC},
			{name: "debugging", type: DYNAMIC},
			// {name: "custom settings", type: DYNAMIC},
			{name: "keybinds", type: DYNAMIC}
		],
		"preferences" => [
			/*
				{
					name: "Gameplay",
					type: DYNAMIC,
					attributes: [UNSELECTABLE]
				},
			 */
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
				description: "If the notes should be centered	.",
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
			/*
				{
					name: "Appearance",
					type: DYNAMIC,
					attributes: [UNSELECTABLE]
				},
			 */
			{
				name: "User Interface Style",
				description: "Choose your UI Style.",
				type: SELECTOR,
				value: "Feather Detailed",
				values: ["FNF Minimal", "FNF Detailed", "Feather Minimal", "Feather Detailed"]
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
				value: false
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
				description: "If moving instances like icons or Camera Zooms should be reduced.",
				type: CHECKMARK,
				value: false
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
				name: "Show RAM Info",
				description: "if the current memory usage should be shown on the Info Counter.",
				type: CHECKMARK,
				value: true
			},
			{
				name: "Show Engine Mark",
				description: "If the current state folder location and object count should be shown on the Info Counter.",
				type: CHECKMARK,
				value: true
			}
		],
		"custom settings" => [{name: "NOTHING", type: DYNAMIC}],
	];

	public static var myPreferences:Map<String, Array<OptionData>> = [];

	/**
		[Saves your game preferences]type
	**/
	public static function savePrefs():Void
	{
		FlxG.save.bind("Feather-Settings" #if (flixel < "5.0.0"), "BeastlyGhost" #end);

		if (FlxG.save.data.preferences == null)
			FlxG.save.data.preferences = myPreferences;

		// FlxG.save.data.flush();
	}

	/**
		[Loads your game preferences]
	**/
	public static function loadPrefs():Void
	{
		FlxG.save.bind("Feather-Settings" #if (flixel < "5.0.0"), "BeastlyGhost" #end);

		for (category => array in preferencesList)
		{
			if (myPreferences.get(category) == null)
				myPreferences.set(category, array);
		}

		/*
			if (FlxG.save.data.preferences != null)
			{
				var savedPreferences = FlxG.save.data.preferences;
				for (key in savedPreferences.keys())
				{
					for (j in 0...savedPreferences.get(key).length)
					{
						if (myPreferences.contains(savedPreferences[j]) && !myPreferences[j].attributes.contains(UNCHANGEABLE))
							//
					}
				}
			}
		 */

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
		for (category => array in preferencesList)
		{
			if (category != null && array != null)
			{
				if (myPreferences.exists(category))
				{
					for (i in 0...array.length)
					{
						if (myPreferences.get(category)[i].name == name)
						{
							var retVal = myPreferences.get(category);
							return (getValue ? retVal[i].value : retVal[i]);
						}
					}
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
		for (category => array in preferencesList)
		{
			if (category != null && array != null)
			{
				if (myPreferences.exists(category))
				{
					for (i in 0...array.length)
					{
						if (myPreferences.get(category)[i].name == name)
						{
							var retVal = myPreferences.get(category);
							retVal[i].value = newValue;
						}
					}
				}
			}
		}
	}

	/**
		[Updates default game preferences data if needed]
	**/
	public static function updatePrefs():Void
	{
		#if (flixel >= "5.0.0")
		flixel.FlxSprite.defaultAntialiasing = getPref('Anti Aliasing');
		#end
		FlxG.drawFramerate = FlxG.updateFramerate = getPref("Framerate Cap");
		FlxG.autoPause = getPref('Auto Pause');
	}
}
