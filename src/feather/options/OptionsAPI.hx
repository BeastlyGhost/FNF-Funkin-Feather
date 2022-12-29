package feather.options;

import flixel.FlxG;

/**
 * a Class that stores every game setting, along with functions to control game settings
**/
class OptionsAPI {
	public static var preferences:Map<String, Dynamic> = [
		// GAMEPLAY
		"Downscroll" => false,
		"Center Notes" => false,
		"Hide Opponent Notes" => false,
		"Ghost Tapping" => false,
		"Safe Frames" => 10,
		// CUSTOMIZATION
		"Show Info Card" => true,
		"Holds behind Receptors" => true,
		"UI Style" => [["feather"], ["vanilla", "feather"]],
		"Quant Style" => [["none"], ["none", "stepmania", "forever"]],
		"Splash Opacity" => 60,
		// ACCESSIBILITY
		"Anti Aliasing" => true,
		"Flashing Lights" => true,
		"Reduce Motion" => false,
		"Score Bopping" => true,
		// MISC
		"Auto Pause" => false,
		"Skip Splash Screen" => false,
		"Show FPS" => true,
		"Accurate FPS" => false,
		"Show RAM" => true,
		"Show Debug" => false,
		"Framerate Cap" => 60,
	];

	public static var myPreferences:Map<String, Dynamic> = [];

	/**
		[Saves your game preferences]
	**/
	public static function savePrefs():Void {
		bindSave("Settings");
		try {
			//saveFile.set('preferences', myPreferences)
			FlxG.save.data.preferences = myPreferences;
		}
		catch (e:Dynamic)
			throw('Unexpected Error when saving preferences, Error: $e');
	}

	/**
		[Loads your game preferences]
	**/
	public static function loadPrefs():Void {
		bindSave("Settings");

		// reset your preferences to the defaults
		for (key => keys in preferences) {
			myPreferences.set(key, keys);
		}

		if (FlxG.save.data.preferences != null) {
			// grab from your save file
			try {
				var savedPreferences:Map<String, Dynamic> = FlxG.save.data.preferences;
				for (key => keys in savedPreferences) {
					// this checks if the key exists on the DEFAULT preferences list
					// if it does, then it sets your preferences to the save keys
					// that way saves won't have to be deleted if preferences change overtime
					if (preferences.get(key) != null) {
						myPreferences.set(key, keys);
					}
				}
			}
			catch (e:Dynamic)
				throw('Something went wrong while loading your saved preferences');
		}

		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;
	}

	/**
		[Returns the specified preference from within the preferences map]
		@param name the `name` of your desired preference
		@param getValue if the option `value` should be returned instead of the option itself
		@return your preference, or the default value for it
	**/
	public static function getPref(name:String, getValue:Bool = true):Dynamic {
		bindSave("Settings");

		var chosenMap:Map<String, Dynamic> = preferences;
		chosenMap = (myPreferences.get(name) != null ? myPreferences : preferences);

		for (option => value in chosenMap) {
			try {
				var valueFinal:Any = chosenMap.get(name);
				if (chosenMap.get(name) is Array)
					valueFinal = chosenMap.get(name)[0][0];

				return (getValue ? valueFinal : option);
			}
			catch (e:Dynamic) {
				throw('Something went wrong while trying to catch this Preference: "$name", Error: $e');
				return null;
			}
		}

		throw('Preference "$name" does not exist in the preferences map.');
		return null;
	}

	/**
		[Sets a new value to the specified preference from within the preferences map]
		@param name the `name` of your desired preference
		@param newValue the new value for your option
	**/
	public static function setPref(name:String, value:Any):Void {
		bindSave("Settings");

		var chosenMap:Map<String, Dynamic> = preferences;
		chosenMap = (myPreferences.get(name) != null ? myPreferences : preferences);

		try {
			var printed:Bool = false;
			var oldValue:Any = chosenMap.get(name);
			var newValue:Any = value;

			if (chosenMap.get(name) is Array) {
				oldValue = chosenMap.get(name)[0];
				newValue = [[value], chosenMap.get(name)[1]];
			}

			if (oldValue != newValue)
				chosenMap.set(name, newValue);

			if (!printed) {
				trace('option: $name - previous value: $oldValue - new value: $newValue');
				printed = true;
			}
		}
		catch (e:Dynamic)
			throw('Something went wrong while trying to catch this Preference: "$name", Error: $e');
	}

	/**
		[Updates default game preferences data if needed]
	**/
	public static function updatePrefs():Void {
		bindSave("Settings");

		if (getPref("Skip Splash Screen") != null)
			Main.game.skipSplash = !getPref("Skip Splash Screen");

		#if (flixel >= "5.0.0")
		var alias:Bool = true;
		if (getPref('Anti Aliasing') != null)
			alias = getPref('Anti Aliasing');

		flixel.FlxSprite.defaultAntialiasing = alias;
		#end

		// to avoid a crash
		var fpsPref:Int = 60;
		if (getPref("Framerate Cap") != null)
			fpsPref = getPref("Framerate Cap");

		FlxG.drawFramerate = FlxG.updateFramerate = fpsPref;

		var autoPause:Bool = true;

		if (getPref('Auto Pause', false) != null)
			autoPause = getPref('Auto Pause');

		FlxG.autoPause = autoPause;
	}

	// public static var saveFile:CocoaSave;

	public static function bindSave(name:String):Void {
		try {
			/**
			if (saveFile == null)
				saveFile = new CocoaSave(name, "pluma");
			else if (saveFile.currentBind != name)
				saveFile.bind(name);
			**/
			if (FlxG.save.name != name)
				FlxG.save.bind(name);
		}
		catch (e:Dynamic)
			trace('Unexpected Error when binding save, file name was "$name", Error: $e');
	}
}
