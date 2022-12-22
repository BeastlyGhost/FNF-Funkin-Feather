package feather;

import flixel.FlxG;
import flixel.util.FlxSave;
import sys.FileSystem;

typedef SaveFile =
{
	var fileName:String;
	var fileData:Dynamic;
}

class FeatherSave
{
	public static var pathBase:String = './assets/data/save';

	public static var saveBinder:Map<String, SaveFile>;

	// generated automatically by random code
	public static var saveHash:Map<String, String>;

	public static function bind(name:String):Void
	{
		if (saveBinder == null)
			saveBinder = new Map<String, SaveFile>();

		if (saveHash == null)
			saveHash = new Map<String, String>();

		saveBinder.set(name, {fileName: name, fileData: null});
		// trace("Data on Save is: " + saveBinder);
	}

	public static function save(name:String, data:Dynamic, ?store:Bool = true):Void
	{
		if (saveBinder == null)
			return;

		if (saveBinder.exists(name))
			saveBinder.set(name, {fileName: name, fileData: data});

		/**
			if (!FileSystem.exists('$pathBase/save'))
				FileSystem.createDirectory('$pathBase/save');

			if (!FileSystem.exists(AssetHelper.grabAsset(name, JSON, 'data/save')))
			{
				var path:String = '$pathBase/$name.json';
				File.saveContent(path, '${saveBinder.get(name)}');
			}
		**/

		trace("Data on Save is: " + saveBinder);
	}

	public static function load(name:String):Void
	{
		if (!FileSystem.exists(AssetHelper.grabAsset(name, JSON, 'data/save')))
			return;
	}

	public static function getSavePath():String
	{
		@:privateAccess
		return #if (flixel < "5.0.0") 'BeastlyGhost' #else FlxG.stage.application.meta.get('company')
			+ '/'
			+ FlxSave.validate(FlxG.stage.application.meta.get('file')) #end;
	}
}
