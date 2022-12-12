package funkin.backend.dependencies;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import funkin.song.Conductor;
import funkin.song.MusicState;
import sys.FileSystem;

/**
	-- @BeastlyGhost --

	this is basically my own custom made `CoolUtil` class from the base game
	it serves the exact same purpose, giving useful tools to work with
**/
class FeatherTools
{
	/**
		@author Shadow_Mario_
	**/
	inline public static function boundTo(value:Float, minValue:Float, maxValue:Float):Float
		return Math.max(minValue, Math.min(maxValue, value));

	/**
	 * hehe funny variable names
	 * 
	 * Handles camera zooming events
	 * @param leCam - Target Camera
	 * @param daZaza - Default Camera Zoom
	 * @param zazaSpeed - Default Camera Speed
	 */
	inline public static function cameraBumpingZooms(leCam:FlxCamera, daZaza:Float = 1.05, zazaSpeed:Float = 1):Void
	{
		var easeLerp = 1 - MusicState.boundFramerate(0.15) * zazaSpeed;
		if (leCam != null)
		{
			// camera stuffs
			leCam.zoom = FlxMath.lerp(daZaza, leCam.zoom, easeLerp);

			// not even forceZoom anymore but still
			leCam.angle = FlxMath.lerp(0, leCam.angle, easeLerp);
		}
	}

	inline public static function cameraBumpReset(curBeat:Int, leCam:FlxCamera, speedVal:Float = 4, resetVal:Float = 0.015):Void
	{
		if ((leCam.zoom < 1.35 && curBeat % speedVal == 0))
			leCam.zoom += resetVal;
	}

	/**
		Formats the song. Example: ``'world_machine' -> 'World Machine'``.
	**/
	inline public static function formatSong(song:String):String
	{
		var song = song.split('_').join(' ');
		var words:Array<String> = song.toLowerCase().split(" ");

		for (i in 0...words.length)
			words[i] = words[i].charAt(0).toUpperCase() + words[i].substr(1);

		return words.join(" ");
	}

	/**
		Checks if the Main Menu Song is playing, if it isn't, then play it!
		@param volumeReset if the song should fade in on a successful song reset
	**/
	inline public static function menuMusicCheck(volumeReset:Bool = false):Void
	{
		if ((FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing)))
		{
			FlxG.sound.playMusic(AssetHandler.grabAsset("freakyMenu", SOUND, "music"), (volumeReset) ? 0 : 0.7);
			if (volumeReset)
				FlxG.sound.music.fadeIn(4, 0, 0.7);
			Conductor.changeBPM(102);
		}
	}

	/**
		Returns an array with the files of the specified directory.
		Example usage:
		var fileArray:Array<String> = CoolUtil.absoluteDirectory('scripts');
		trace(fileArray); -> ['mods/scripts/modchart.hx', 'assets/scripts/script.hx']
	**/
	inline public static function absoluteDirectory(file:String):Array<String>
	{
		if (!file.endsWith('/'))
			file = '$file/';

		var path:String = AssetHandler.grabRoot(file, DIRECTORY);

		var absolutePath:String = FileSystem.absolutePath(path);
		var directory:Array<String> = FileSystem.readDirectory(absolutePath);

		if (directory != null)
		{
			var dirCopy:Array<String> = directory.copy();

			for (i in dirCopy)
			{
				var index:Int = dirCopy.indexOf(i);
				var file:String = '$path$i';
				dirCopy.remove(i);
				dirCopy.insert(index, file);
			}

			directory = dirCopy;
		}

		return if (directory != null) directory else [];
	}

	inline public static function getDifficulty(diff:Int = 0):String
	{
		return funkin.backend.data.SongManager.defaultDiffs[diff];
	}

	inline public static function openURL(link:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [link]);
		#else
		FlxG.openURL(link);
		#end
	}
}

/**
	Flixel Sprite Extension made for characters! 
**/
class FeatherSprite extends FlxSprite
{
	//
	public var animOffsets:Map<String, Array<Dynamic>>;

	public function new(x:Float = 0, y:Float = 0):Void
	{
		animOffsets = new Map<String, Array<Dynamic>>();
		super();
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset:Array<Dynamic> = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
			offset.set(daOffset[0], daOffset[1]);
		else
			offset.set(0, 0);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0):Void
		animOffsets[name] = [x, y];

	override public function destroy()
	{
		if (graphic != null)
			graphic.dump();
		super.destroy();
	}
}

/**
	a Sprite that follows a parent sprite
**/
class FeatherAttachedSprite extends FeatherSprite
{
	public var parentSprite:FlxSprite;

	public var addX:Float = 0;
	public var addY:Float = 0;
	public var addAngle:Float = 0;
	public var addAlpha:Float = 0;

	public var copyParentAngle:Bool = false;
	public var copyParentAlpha:Bool = false;
	public var copyParentVisib:Bool = false;

	public function new(fileName:String, ?fileFolder:String, ?fileAnim:String, ?looped:Bool = false):Void
	{
		super(x, y);

		if (fileName != null)
		{
			if (fileAnim != null)
			{
				frames = AssetHandler.grabAsset(fileName, SPARROW, fileFolder);
				animation.addByPrefix('static', fileAnim, 24, looped);
				animation.play('static');
			}
			else
				loadGraphic(AssetHandler.grabAsset(fileName, IMAGE, fileFolder));
			scrollFactor.set();
		}
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// set parent sprite stuffs;
		if (parentSprite != null)
		{
			setPosition(parentSprite.x + addX, parentSprite.y + addY);
			scrollFactor.set(parentSprite.scrollFactor.x, parentSprite.scrollFactor.y);

			if (copyParentAngle)
				angle = parentSprite.angle + addAngle;

			if (copyParentAlpha)
				alpha = parentSprite.alpha * addAlpha;

			if (copyParentVisib)
				visible = parentSprite.visible;
		}
	}
}
