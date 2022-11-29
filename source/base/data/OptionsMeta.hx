package base.data;

import flixel.FlxG;

enum OptionType
{
	BOOLEAN;
	STRING;
	DYNAMIC;
}

typedef CategoryMetadata =
{
	var name:String;
	var type:String;
	var ?description:String;
}

typedef OptionsMetadata =
{
	var name:String;
	var value:Dynamic;
	var ?description:String;
	var ?type:OptionType; // defaults to DYNAMIC if null
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
	public static var preferences:Array<OptionsMetadata> = [
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
			description: "If the notes should go from top to bottom.",
			type: BOOLEAN,
			value: false
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
			name: "Show Objects",
			description: "If the current state object count should be shown on the Info Counter.",
			type: BOOLEAN,
			value: false
		}
	];

	/**
	 * [Saves your game preferences with "Ghost" as the save file name]
	**/
	public static function savePrefs()
	{
		#if (flixel < "5.0.0")
		FlxG.save.bind("Project-Feather", "BeastlyGhost");
		#end
		FlxG.save.data.preferences = preferences;
		FlxG.save.data.flush();
	}

	/**
	 * [Loads your game preferences with "Ghost" as the save file name]
	**/
	public static function loadPrefs()
	{
		#if (flixel < "5.0.0")
		FlxG.save.bind("Project-Feather", "BeastlyGhost");
		#end

		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;
		if (FlxG.save.data.seenSplash != null)
			Main.game.skipSplash = FlxG.save.data.seenSplash;
		if (FlxG.save.data.preferences != null)
			preferences = FlxG.save.data.preferences;

		updatePrefs();
	}

	/**
	 * [Returns the specified preference from within the preferences map]
	 * @param name the `name` of your desired preference
	 * @return the default / current parameter for your preference
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
	 * [Updates default game preferences data if needed]
	**/
	public static function updatePrefs()
	{
		flixel.FlxSprite.defaultAntialiasing = getPref('Anti Aliasing');
		FlxG.autoPause = getPref('Auto Pause');
	}
}
