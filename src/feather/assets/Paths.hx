package feather.assets;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.media.Sound;

/**
	Here's the Paths class from the base game
	this is used for retrocompatibility with older base game scripts and such
**/
class Paths {
	inline public static function image(key:String, ?library:String):FlxGraphic {
		if (library == null)
			library = "images";
		return AssetHelper.grabAsset(key, IMAGE, library);
	}

	inline public static function getSparrowAtlas(key:String, ?library:String):FlxGraphic {
		if (library == null)
			library = "images";
		return AssetHelper.grabAsset(key, SPARROW, library);
	}
}

/**
	Asset Library Class, basically a copy of paths for use with scripts
	so you can access folders from within the script's origin folder
**/
class AssetLibrary {
	public var localLibrary:String;

	public function new(?localLibrary:String):Void
		this.localLibrary = localLibrary;

	inline function getPreloadPath(file:String):String
		return AssetHelper.grabRoot(file);

	inline function image(key:String, ?library:String):FlxGraphic {
		library = reloadLibrary("images");
		return AssetHelper.grabAsset(key, IMAGE, library);
	}

	inline function font(key:String, ?library:String):String {
		library = reloadLibrary("data/fonts");
		return AssetHelper.grabAsset(key, FONT, library);
	}

	inline function txt(key:String, ?library:String):String
		return AssetHelper.grabAsset(key, TEXT, library);

	inline function json(key:String, ?library:String):String
		return AssetHelper.grabAsset(key, JSON, library);

	inline function sound(key:String, ?library:String):Sound {
		library = reloadLibrary("sounds");
		return AssetHelper.grabAsset(key, SOUND, library);
	}

	inline function soundRandom(key:String, min:Int, max:Int, ?library:String):Sound {
		library = reloadLibrary("sounds");
		return AssetHelper.grabAsset(key + FlxG.random.int(min, max), SOUND, library);
	}

	inline function music(key:String, ?library:String):Sound {
		library = reloadLibrary("music");
		return AssetHelper.grabAsset(key, SOUND, library);
	}

	inline function module(key:String, ?library:String):String {
		library = reloadLibrary("scripts");
		return AssetHelper.grabAsset(key, MODULE, library);
	}

	inline function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames {
		library = reloadLibrary("images");
		return AssetHelper.grabAsset(key, SPARROW, library);
	}

	inline function getPackerAtlas(key:String, ?library:String):FlxAtlasFrames {
		library = reloadLibrary("images");
		return AssetHelper.grabAsset(key, PACKER, library);
	}

	inline private final function reloadLibrary(newLibrary:String):String {
		var library:String = null;
		library = (localLibrary != null ? localLibrary + '/$newLibrary' : newLibrary);
		return library;
	}
}
