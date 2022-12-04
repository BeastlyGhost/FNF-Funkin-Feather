package funkin.backend.data;

import flixel.FlxG;

enum OptionType
{
	BOOLEAN;
	STRING;
	INTEGER;
	FLOAT;
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
	var ?max:Dynamic;
	var ?description:String;
	var ?type:OptionType; // defaults to DYNAMIC if null
	var ?attributes:Array<OptionAttribute>;
}

/**
 * a Class that stores every game setting, along with functions to control game settings
**/
class OptionsMeta
{
	/*
		the Preferences Array sets up settings and default setting parameters
		it can be used alongside a menu for changing said paramaters to new ones
	**/
	public static var preferences:Array<OptionData> = [
		//
		{
			name: "Auto Pause",
			description: "If the game should pause itself when the window is unfocused.",
			type: BOOLEAN,
			value: false
		},
		{
			name: "Anti Aliasing",
			description: "If sprite antialiasing should be disabled, may improve performance.",
			type: BOOLEAN,
			value: true
		},
		{
			name: "Ghost Tapping",
			description: "If you should be able to spam when there's no notes to hit during gameplay.",
			type: BOOLEAN,
			value: true
		},
		{
			name: "Show Grades",
			description: "If misses, accuracy and grades should be shown during gameplay.",
			type: BOOLEAN,
			value: true
		},
		{
			name: "Downscroll",
			description: "If the notes should come from top to bottom.",
			type: BOOLEAN,
			value: false
		},
		{
			name: "Safe Frames",
			description: "Specify the amount of frames you have for hitting notes early / late",
			type: FLOAT,
			value: 10,
			max: 10
		},
		{
			name: "Flashing Lights",
			description: "If menus and songs should have Flashing Effects.",
			type: BOOLEAN,
			value: true
		},
		{
			name: "Show Framerate",
			description: "If the current framerate should be shown on the Info Counter.",
			type: BOOLEAN,
			value: true
		},
		{
			name: "Show Memory",
			description: "if the current memory usage should be shown on the Info Counter.",
			type: BOOLEAN,
			value: true
		},
		{
			name: "Show Debug",
			description: "If the current state folder location and object count should be shown on the Info Counter.",
			type: BOOLEAN,
			value: false
		},
		{
			name: "Framerate Cap",
			description: "Set your desired FPS limit.",
			type: INTEGER,
			value: 120,
			max: 360
		}
	];

	public static var myPreferences:Array<OptionData> = [];

	/**
		[Saves your game preferences]
	**/
	public static function savePrefs()
	{
		#if (flixel < "5.0.0")
		FlxG.save.bind("Funkin-Feather", "BeastlyGhost");
		#end
		FlxG.save.data.preferences = myPreferences;
		FlxG.save.data.flush();
	}

	/**
		[Loads your game preferences]
	**/
	public static function loadPrefs()
	{
		#if (flixel < "5.0.0")
		FlxG.save.bind("Funkin-Feather", "BeastlyGhost");
		#end

		for (i in 0...preferences.length)
		{
			if (!myPreferences.contains(preferences[i]))
			{
				myPreferences.push({
					name: preferences[i].name,
					description: preferences[i].description,
					type: preferences[i].type,
					value: preferences[i].value,
					attributes: preferences[i].attributes,
					max: preferences[i].max
				});
			}

			/*
				if (FlxG.save.data.preferences != null)
				{
					var savedPreferences = FlxG.save.data.preferences;
					for (j in 0...savedPreferences.length)
					{
						if (myPreferences.contains(savedPreferences[j]) && !myPreferences[j].attributes.contains(UNCHANGEABLE))
							//
					}
				}
			 */
		}

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
		@return the default / current parameter for your preference
	**/
	public static function getPref(name:String):Dynamic
	{
		for (i in 0...preferences.length)
		{
			if (preferences[i].name == name)
				return preferences[i].value;
		}

		trace('Preference "$name" does not exist in the preferences map.');
		return null;
	}

	/**
		[Updates default game preferences data if needed]
	**/
	public static function updatePrefs()
	{
		#if (flixel >= "5.0.0")
		flixel.FlxSprite.defaultAntialiasing = getPref('Anti Aliasing');
		#end
		FlxG.autoPause = getPref('Auto Pause');
	}

	public static var optionList:Map<String, Array<String>> = [
		"gameplay" => ["Downscroll", "Ghost Tapping", "Show Grades", "Safe Frames"],
		"accessibility" => ["Auto Pause", "Anti Aliasing", "Flashing Lights"],
		"debugging" => ["Framerate Cap", "Show Framerate", "Show Memory", "Show Debug"],
		"custom settings" => [],
	];
}
