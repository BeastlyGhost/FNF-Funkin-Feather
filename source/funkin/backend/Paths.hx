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
		return AssetHandler.grabRoot(file);

	inline public static function image(key:String, ?library:String):FlxGraphic
	{
		if (library == null || library.length > 1)
			library = "images";
		return AssetHandler.grabAsset(key, IMAGE, library);
	}

	inline public static function font(key:String, ?library:String):String
	{
		if (library == null || library.length > 1)
			library = "data/fonts";
		return AssetHandler.grabAsset(key, FONT, library);
	}

	inline public static function txt(key:String, ?library:String):String
		return AssetHandler.grabAsset(key, TEXT, library);

	inline public static function json(key:String, ?library:String):String
		return AssetHandler.grabAsset(key, JSON, library);

	inline public static function sound(key:String, ?library:String):Sound
	{
		if (library == null || library.length > 1)
			library = "sounds";
		return AssetHandler.grabAsset(key, SOUND, library);
	}

	inline public static function soundRandom(key:String, min:Int, max:Int, ?library:String):Sound
	{
		if (library == null || library.length > 1)
			library = "sounds";
		return AssetHandler.grabAsset(key + FlxG.random.int(min, max), SOUND, library);
	}

	inline public static function music(key:String, ?library:String):Sound
	{
		if (library == null || library.length > 1)
			library = "music";
		return AssetHandler.grabAsset(key, SOUND, library);
	}

	inline public static function module(key:String, ?library:String):String
	{
		if (library == null || library.length > 1)
			library = 'scripts';
		return AssetHandler.grabAsset(key, MODULE, library);
	}

	inline public static function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		if (library == null || library.length > 1)
			library = "images";
		return AssetHandler.grabAsset(key, SPARROW, library);
	}

	inline public static function getPackerAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		if (library == null || library.length > 1)
			library = "images";
		return AssetHandler.grabAsset(key, PACKER, library);
	}
}
