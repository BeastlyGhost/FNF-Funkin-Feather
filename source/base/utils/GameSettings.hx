package base.utils;

import flixel.FlxG;

/**
 * a Class that stores every game setting, along with functions to control game settings
**/
class GameSettings
{
	/*
		the Preferences Map sets up settings and default setting parameters
		it can be used alongside a menu for changing said paramaters to new ones
	**/
	public static var preferences:Map<String, Dynamic> = [
		//
		"Auto Pause" => false,
		"Anti Aliasing" => true,
		"Ghost Tapping" => false,
		"Downscroll" => false,
		"Flashing Lights" => true,
		"Show Framerate" => true,
		"Show Memory" => true,
		"Show Objects" => true,
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
	public static function getPref(name:String)
	{
		if (preferences.exists(name))
			return preferences.get(name);
		//
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
