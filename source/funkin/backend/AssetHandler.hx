package funkin.backend;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.Assets;
import openfl.media.Sound;
import openfl.system.System;
import sys.FileSystem;
import sys.io.File;

/**
	Enumerator for Asset Types, right now, there isn't much going on with this
	it just defines what Asset Type we are dealing with, and gives extensions to said asset type
**/
enum AssetType
{
	DIRECTORY;
	SPARROW;
	PACKER;
	VIDEO;
	SOUND;
	FONT;
	MODULE;
	IMAGE;
	JSON;
	TEXT;
	YAML;
}

/**
	Typedefine for Cached Assets, simply put, it defines what `type` an asset is, and what data it comes with
	data can be anything, as we are going to use it to later `grab` it in order to manage said data
**/
typedef CacheableAsset =
{
	var type:AssetType;
	var data:Dynamic;
}

/**
	This is the Assets Class, meant to allow access to assets, and manage used ones
**/
class AssetHandler
{
	/**
		Stores only user-preferred assets that should not be cleared when `clear` is called
	**/
	public static var persistentAssets:Array<String> = ['alphabet', 'menuBG', 'menuDesat'];

	/**
		Stores Tracked Assets on a Map

		-- @BeastlyGhost --

		I have yet to understand how asset managment works properly
		so if this looks weird, that's because it might be, i've decided that
		instead of creating multiple maps for various type of assets
		having a single one could be somewhat easier to manage
	**/
	public static var mappedAssets:Map<AssetType, Map<String, CacheableAsset>> = [
		//
		IMAGE => new Map<String, CacheableAsset>(),
		SOUND => new Map<String, CacheableAsset>(),
		VIDEO => new Map<String, CacheableAsset>(),
	];

	/**
		Stores every tracked asset in an Array, useful for cleaning up later on
	**/
	public static var trackedAssets:Array<String> = [];

	/**
		Returns a specified asset

		example usage:

		`AssetHandler.grabAsset("default/base/NOTE_assets", SPARROW, "data/notes");`

		-----------------------------

		@param asset the asset name
		@param type the asset type (like: IMAGE, SOUND, FONT for example)
		@param directory the directory we should look for the specified asset name
		@return your asset path along with the asset and its extensions (if null, then nothing)
	**/
	public static function grabAsset(asset:String, type:AssetType, directory:String):Dynamic
	{
		//
		var path = grabRoot('$directory/$asset', type);
		if (FileSystem.exists(path))
		{
			switch (type)
			{
				case JSON:
					var json:String = File.getContent(path);
					while (!json.endsWith("}"))
						json = json.substr(0, json.length - 1);
					return json;
				case YAML:
					var yaml:String = Yaml.parse(path);
					return yaml;
				case SPARROW:
					return FlxAtlasFrames.fromSparrow(grabAsset(asset, IMAGE, directory), File.getContent(path));
				case PACKER:
					return FlxAtlasFrames.fromSpriteSheetPacker(grabAsset(asset, IMAGE, directory), File.getContent(path));
				case IMAGE:
					return grabGraphic(path);
				case SOUND:
					return grabSound(path);
				default:
					return path;
			}
		}

		trace('$type asset is returning null at $path');
		return null;
	}

	/**
		Stores a graphic asset from the specified directory, then returns it
		@param outputDir the directory we should look for
		@return uses `FlxGraphic`'s `fromBitmapData` function to return your graphic asset
	**/
	public static function grabGraphic(outputDir:String):FlxGraphic
	{
		if (!mappedAssets[IMAGE].exists(outputDir))
		{
			var myGraphic:FlxGraphic = FlxGraphic.fromAssetKey(outputDir, false, null, false);
			myGraphic.persist = true;
			mappedAssets[IMAGE].set(outputDir, {type: IMAGE, data: myGraphic});
			trackedAssets.push(outputDir);
		}
		return returnGraphic(outputDir);
	}

	/**
		Returns a graphic asset from the specified directory
		@param outputDir the directory we should look for
		@return the output graphic from within the mapped assets map
	**/
	public static function returnGraphic(outputDir:String):FlxGraphic
	{
		if (FlxG.bitmap.checkCache(outputDir))
			return FlxG.bitmap.get(outputDir);
		if (mappedAssets[IMAGE].exists(outputDir))
			return mappedAssets[IMAGE].get(outputDir).data;

		trace('graphic asset is returning null at $outputDir');
		return null;
	}

	/**
		Returns a sound from the specified directory
		@param outputDir the directory we should look for
		@return uses OpenFL's sound feature to return a sound from the specified directory
	**/
	public static function grabSound(outputDir:String):Sound
	{
		if (!mappedAssets[SOUND].exists(outputDir))
			mappedAssets[SOUND].set(outputDir, {type: SOUND, data: Sound.fromFile(outputDir)});
		trackedAssets.push(outputDir);
		return mappedAssets[SOUND].get(outputDir).data;
	}

	/**
		Returns the main assets directory
		@param directory folder that we should return along with the main assets folder
		@param type the type of asset you need, leave it as blank for returning a directory instead
		@return the main assets directory with a specified subdirectory (and extension, if type is given)
	**/
	public static function grabRoot(directory:String, ?type:AssetType):String
	{
		//
		var dir:String = '';
		if (directory != null)
			dir = '/$directory';
		return getExtensions('assets$dir', type);
	}

	/**
		Filters through asset types and returns extensions for said assets
		@param dir the directory we should get the extension from
		@param type the asset type (like: image, font, sound)
		 @return if extension is valid, returns your path with the extension, else only the path
	**/
	public static function getExtensions(dir:String, type:AssetType):String
	{
		var extensions:Array<String> = null;
		switch (type)
		{
			case IMAGE:
				extensions = ['.png', '.jpg'];
			case VIDEO:
				extensions = ['.mp4'];
			case FONT:
				extensions = [".ttf", ".otf"];
			case SOUND:
				extensions = ['.ogg', '.wav'];
			case JSON:
				extensions = ['.json'];
			case YAML:
				extensions = ['.yaml'];
			case SPARROW:
				extensions = ['.xml'];
			case PACKER | TEXT:
				extensions = ['.txt'];
			case MODULE:
				extensions = ['.hx', '.hxs', '.hxc', '.hscript'];
			default:
				extensions = null;
		}

		if (extensions != null)
		{
			for (i in extensions)
			{
				var assetPath:String = '$dir$i';
				if (FileSystem.exists(assetPath))
					return assetPath;
			}
		}

		return dir;
	}

	/**
		Simply put, this clears all tracked assets that exist on the `trackedAssets` array
		@param clearMappedImages whether images should also be cleared along with sounds
	**/
	public static function clear(clearUnusedImages:Bool, ?clearMappedImages:Bool):Void
	{
		if (clearMappedImages)
		{
			@:privateAccess
			for (asset in FlxG.bitmap._cache.keys())
			{
				var bitmap = FlxG.bitmap._cache.get(asset);
				if (bitmap != null && !mappedAssets[IMAGE].exists(asset))
				{
					Assets.cache.removeBitmapData(asset);
					FlxG.bitmap._cache.remove(asset);
					bitmap.destroy();
				}
			}
		}

		if (clearUnusedImages)
		{
			for (asset in mappedAssets[IMAGE].keys())
			{
				if (!persistentAssets.contains(asset) && !trackedAssets.contains(asset))
				{
					// grab the image asset
					var bitmap = mappedAssets[IMAGE].get(asset);
					if (bitmap != null)
					{
						@:privateAccess
						if (Assets.cache.hasBitmapData(bitmap.data))
						{
							// remove it from the assets cache if it exists, then destroy it
							Assets.cache.removeBitmapData(bitmap.data);
							FlxG.bitmap._cache.remove(bitmap.data);
							bitmap.data.destroy();
						}

						// and remove it from the mapped assets
						mappedAssets[IMAGE].remove(asset);
					}
				}
			}
		}

		for (asset in mappedAssets[SOUND].keys())
		{
			if (asset != null && !persistentAssets.contains(asset) && !trackedAssets.contains(asset))
			{
				Assets.cache.clear(asset);
				mappedAssets[SOUND].remove(asset);
			}
		}

		trackedAssets = [];

		// run the system garbage collector
		System.gc();
	}
}
