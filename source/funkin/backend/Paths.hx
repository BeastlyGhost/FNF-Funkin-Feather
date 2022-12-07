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
		return AssetHandler.grabAsset(key, IMAGE, "images");

	inline public static function font(key:String, ?library:String):String
		return AssetHandler.grabAsset(key, FONT, "data/fonts");

	inline public static function txt(key:String, ?library:String):String
		return AssetHandler.grabAsset(key, TEXT, null);

	inline public static function json(key:String, ?library:String):String
		return AssetHandler.grabAsset(key, JSON, null);

	inline public static function sound(key:String, ?library:String):Sound
		return AssetHandler.grabAsset(key, SOUND, "sounds");

	inline public static function soundRandom(key:String, min:Int, max:Int, ?library:String):Sound
		return AssetHandler.grabAsset(key + FlxG.random.int(min, max), SOUND, "sounds");

	inline public static function music(key:String, ?library:String):Sound
		return AssetHandler.grabAsset(key, SOUND, "music");

	inline public static function module(key:String, folder:String = null, ?library:String):String
	{
		if (folder == null || folder.length > 1)
			folder = 'scripts';
		return AssetHandler.grabAsset(key, MODULE, folder);
	}

	inline public static function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
		return AssetHandler.grabAsset(key, SPARROW, "images");

	inline public static function getPackerAtlas(key:String, ?library:String):FlxAtlasFrames
		return AssetHandler.grabAsset(key, PACKER, "images");
}
