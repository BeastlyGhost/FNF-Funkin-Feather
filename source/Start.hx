package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

/**
 * Starting Class for the game
 * used to set up useful functions and variables for the main game!
**/
class Start extends FlxState
{
	/*
		the Preferences Map sets up settings and default setting parameters
		it can be used alongside a menu for changing said paramaters to new ones
	**/
	public static var preferences:Map<String, Dynamic> = [
		//
		"Anti Aliasing" => true,
		"Auto Pause" => false,
		"Downscroll" => false,
		"Show Framerate" => true,
		"Show Memory" => true,
		"Show Objects" => true,
	];

	/**
	 * [Saves your game preferences with "Ghost" as the save file name]
	**/
	public static function savePrefs()
	{
		FlxG.save.bind("Project-Feather", "BeastlyGhost");
		FlxG.save.data.preferences = preferences;
		// FlxG.save.data.flush();
	}

	/**
	 * [Loads your game preferences with "Ghost" as the save file name]
	**/
	public static function loadPrefs()
	{
		FlxG.save.bind("Project-Feather", "BeastlyGhost");

		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;
		// if (FlxG.save.data.preferences != null)
		// preferences = FlxG.save.data.preferences;

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
		FlxSprite.defaultAntialiasing = getPref('Anti Aliasing');
		FlxG.autoPause = getPref('Auto Pause');
	}

	override public function create()
	{
		super.create();

		loadPrefs();

		FlxG.fixedTimestep = true;
		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = false;

		if (FlxG.save.data.seenSplash != null)
			Main.game.skipSplash = FlxG.save.data.seenSplash;

		triggerSplash(Main.game.skipSplash);
	}

	function triggerSplash(skip:Bool):Void
	{
		if (skip)
			return FlxG.switchState(cast Type.createInstance(Main.game.initialState, []));

		var bianca:FlxSprite = new FlxSprite().loadGraphic(AssetHandler.grabAsset("biancaSplash", IMAGE, "images/menus"));
		bianca.setGraphicSize(Std.int(bianca.width * 0.6));
		bianca.screenCenter(XY);
		bianca.x -= 20;
		add(bianca);

		FlxG.sound.play(AssetHandler.grabAsset("splashRingSound", SOUND, "sounds/ui"));

		FlxTween.tween(bianca, {alpha: 0}, 2, {
			onComplete: t ->
			{
				if (FlxG.save.data.seenSplash != null)
					FlxG.save.data.seenSplash = true;
				FlxG.switchState(cast Type.createInstance(Main.game.initialState, []));
			},
			ease: FlxEase.sineOut
		});
	}
}
