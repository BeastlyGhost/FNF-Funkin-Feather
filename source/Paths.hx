package;

import flixel.FlxG;

/**
	Here's the Paths class from the base game
	this is used for retrocompatibility with older base game scripts and such
**/
class Paths
{
	inline public static function getPreloadPath(file:String)
		return AssetHandler.grabRoot(file);

	inline public static function image(key:String, ?library:String)
		return AssetHandler.grabAsset(key, IMAGE, "images");

	inline public static function font(key:String, ?library:String)
		return AssetHandler.grabAsset(key, FONT, "data/fonts");

	inline public static function sound(key:String, ?library:String)
		return AssetHandler.grabAsset(key, SOUND, "sounds");

	inline public static function soundRandom(key:String, min:Int, max:Int, ?library:String)
		return AssetHandler.grabAsset(key + FlxG.random.int(min, max), SOUND, "sounds");

	inline public static function music(key:String, ?library:String)
		return AssetHandler.grabAsset(key, SOUND, "music");

	inline public static function getSparrowAtlas(key:String, ?library:String)
		return AssetHandler.grabAsset(key, SPARROW, "images");

	inline public static function getPackerAtlas(key:String, ?library:String)
		return AssetHandler.grabAsset(key, PACKER, "images");
}
