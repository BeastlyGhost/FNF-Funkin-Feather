package base.utils;

import base.song.MusicState;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.math.FlxMath;

interface IMusicBeat
{
	public var curBeat:Int; // Defines the Current Beat on the Current Song
	public var curStep:Int; // Defines the Current Step on the Current Song
	public var curSection:Int; // Defines the Current Section on the Current Song
	public function beatHit():Void; // Decides what to do when a Beat is hit
	public function sectionHit():Void; // Decides what to do when a Section is hit
	public function stepHit():Void; // Decides what to do when a Step is hit, also updates beats
	public function endSong():Void; // a Function to decide what to do when a song ends
}

class FeatherUtils
{
	/**
	 * hehe funny variable names
	 * 
	 * Handles camera zooming events
	 * @param leCam - Target Camera
	 * @param daZaza - Default Camera Zoom
	 * @param zazaSpeed - Default Camera Speed
	 */
	inline public static function cameraBumpingZooms(leCam:FlxCamera, daZaza:Float = 1.05, zazaSpeed:Float = 1)
	{
		var easeLerp = 1 - MusicState.boundFramerate(0.05) * zazaSpeed;
		if (leCam != null)
		{
			// camera stuffs
			leCam.zoom = FlxMath.lerp(daZaza, leCam.zoom, easeLerp);

			// not even forceZoom anymore but still
			leCam.angle = FlxMath.lerp(0, leCam.angle, easeLerp);
		}
	}

	inline public static function cameraBumpReset(curBeat:Int, leCam:FlxCamera, speedVal:Float = 4, resetVal:Float = 0.015)
	{
		if ((leCam.zoom < 1.35 && curBeat % speedVal == 0))
			leCam.zoom += resetVal;
	}
}

/**
 * Flixel Sprite Extension made for characters! 
**/
class FeatherSprite extends FlxSprite
{
	//
	public var animOffsets:Map<String, Array<Dynamic>>;

	public function new(x:Float, y:Float)
	{
		animOffsets = new Map<String, Array<Dynamic>>();

		super();
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
			offset.set(daOffset[0], daOffset[1]);
		else
			offset.set(0, 0);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
		animOffsets[name] = [x, y];
}
