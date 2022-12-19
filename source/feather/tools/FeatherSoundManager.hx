package feather.tools;

import flixel.FlxG;
import flixel.system.FlxSound;

/**
	the Sound Manager class contains various tools for sound controls and such
	WIP
**/
class FeatherSoundManager
{
	private static var createdSound:FlxSound;

	public static function playSound(name:String, folder:String = "sounds", persist:Bool = false, volume:Float = 1):Void
	{
		createdSound = new FlxSound().loadEmbedded(AssetHelper.grabAsset(name, SOUND, folder));
		createdSound.volume = volume;
		createdSound.persist = persist;
		createdSound.play();
	}

	public static function loseFocus():Void
	{
		if (!FlxG.autoPause)
			return;

		if (createdSound != null)
			if (createdSound.playing)
				createdSound.pause();
	}

	public static function gainFocus():Void
	{
		if (createdSound != null)
			if (!createdSound.playing)
				createdSound.resume();
	}

	public static function update():Void
	{
		if (createdSound != null)
			if (createdSound.time == createdSound.length)
				createdSound.stop();
	}

	/**
		Persona 3 Mass Destruction
	**/
	public static function destroy():Void
	{
		if (createdSound != null)
			createdSound.stop();
	}
}
