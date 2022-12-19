package funkin.backend;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.media.Sound;

/**
	Here's the Paths class from the base game
	this is used for retrocompatibility with older base game scripts and such
**/
class Paths
{
	inline public static function getPreloadPath(file:String):String
		return AssetHelper.grabRoot(file);

	inline public static function image(key:String, ?library:String):FlxGraphic
	{
		if (library == null)
			library = "images";
		return AssetHelper.grabAsset(key, IMAGE, library);
	}

	inline public static function font(key:String, ?library:String):String
	{
		if (library == null)
			library = "data/fonts";
		return AssetHelper.grabAsset(key, FONT, library);
	}

	inline public static function txt(key:String, ?library:String):String
		return AssetHelper.grabAsset(key, TEXT, library);

	inline public static function json(key:String, ?library:String):String
		return AssetHelper.grabAsset(key, JSON, library);

	inline public static function sound(key:String, ?library:String):Sound
	{
		if (library == null)
			library = "sounds";
		return AssetHelper.grabAsset(key, SOUND, library);
	}

	inline public static function soundRandom(key:String, min:Int, max:Int, ?library:String):Sound
	{
		if (library == null)
			library = "sounds";
		return AssetHelper.grabAsset(key + FlxG.random.int(min, max), SOUND, library);
	}

	inline public static function music(key:String, ?library:String):Sound
	{
		if (library == null)
			library = "music";
		return AssetHelper.grabAsset(key, SOUND, library);
	}

	inline public static function module(key:String, ?library:String):String
	{
		if (library == null)
			library = 'scripts';
		return AssetHelper.grabAsset(key, MODULE, library);
	}

	inline public static function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		if (library == null)
			library = "images";
		return AssetHelper.grabAsset(key, SPARROW, library);
	}

	inline public static function getPackerAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		if (library == null)
			library = "images";
		return AssetHelper.grabAsset(key, PACKER, library);
	}
}
