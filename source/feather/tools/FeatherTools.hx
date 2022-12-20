package feather.tools;

import feather.assets.AssetGroup;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.util.FlxAxes;
import funkin.essentials.song.Conductor;
import funkin.essentials.song.MusicState;
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
		var easeLerp = 1 - MusicState.boundFramerate(0.1) * zazaSpeed;
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
			FlxG.sound.playMusic(AssetHelper.grabAsset("freakyMenu", SOUND, "music"), (volumeReset) ? 0 : 0.7);
			if (volumeReset)
				FlxG.sound.music.fadeIn(4, 0, 0.7);
			Conductor.changeBPM(102);
		}
	}

	/**
		Returns an array of libraries from your specified destination
		@dest the directory that should be read
	**/
	inline public static function readDirectory(dest:String, ?type:AssetType):Array<String>
	{
		var libraryArray:Array<String> = [];

		for (dir in FileSystem.readDirectory(AssetHelper.grabRoot(dest, type)))
		{
			if (!libraryArray.contains(dir))
				libraryArray.push(dir);
			trace(libraryArray);
		}

		return if (libraryArray != null) libraryArray else [];
	}

	inline public static function getDifficulty(diff:Int = 0):String
	{
		return funkin.essentials.song.SongManager.defaultDiffs[diff];
	}

	inline public static function getAxes(axe:String = 'xy'):FlxAxes
	{
		switch (axe)
		{
			case "x":
				return FlxAxes.X;
			case "y":
				return FlxAxes.Y;
			default:
				return FlxAxes.XY;
		}
		return FlxAxes.XY;
	}

	inline public static function openURL(link:String):Void
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [link]);
		#else
		FlxG.openURL(link);
		#end
	}
}
