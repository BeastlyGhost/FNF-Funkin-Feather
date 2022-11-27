package base.song;

import base.Transition;
import base.song.Conductor.BPMChangeEvent;
import base.utils.FeatherInterfaces.IMusicBeat;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import states.PlayState;

/**
 * Music State is a simple class in which doesn't extend anything
 * it is meant only for storing useful functions
 * 
 * however, in the HX file, we also keep `MusicBeatState` and `MusicBeatSubstate` 
**/
class MusicState
{
	public static function boundFramerate(input:Float)
		return input * (60 / FlxG.drawFramerate);

	public static function switchState(state:FlxState)
	{
		if (!FlxTransitionableState.skipNextTransIn)
		{
			Transition.start(0.3, true, Fade, FlxEase.linear, function()
			{
				FlxG.switchState(state);
			});
			return;
		}
		else
		{
			FlxTransitionableState.skipNextTransIn = false;
			FlxTransitionableState.skipNextTransOut = false;
			FlxG.switchState(state);
		}
	}
}

/**
 * a State that is widely used by the other game states
 * it contains useful tools that can be used by every other state
**/
class MusicBeatState extends FlxUIState implements IMusicBeat
{
	public var curBeat:Int = 0;
	public var curStep:Int = 0;
	public var curSection:Int = 0;

	public var lastBeat:Int = 0;
	public var lastStep:Int = 0;
	public var lastSection:Int = 0;

	public var selection:Int = 0; // Defines the Current Selected Item on a State
	public var wrappableGroup:Array<Dynamic> = []; // Defines the `selection` limits

	override public function create()
	{
		// clear assets cache
		AssetHandler.clear(true);

		// play the transition if we are allowed to
		if (!FlxTransitionableState.skipNextTransOut)
			Transition.start(0.3, false, Fade, FlxEase.linear);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			FlxG.sound.music.onComplete = endSong;

		updateSongContents();

		FlxG.watch.add(Conductor, "songPosition");
		FlxG.watch.add(this, "curBeat");
		FlxG.watch.add(this, "curStep");
		FlxG.watch.add(this, "curSection");

		super.update(elapsed);
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (FlxG.sound.music != null)
			Conductor.pauseSong();

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (!isEndingSong)
			Conductor.resyncVocals();

		super.closeSubState();
	}

	public function updateSongContents()
	{
		curBeat = Math.floor(curStep / 4);
		curSection = Math.floor(curStep / 16);

		// Update Steps
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}

		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);

		if (lastStep != curStep)
		{
			if (curStep > 0)
				stepHit();
			lastStep = curStep;

			if (PlayState.song != null)
			{
				if (lastStep < curStep)
					sectionHit();
			}
		}
	}

	public function sectionHit()
	{
		if (lastSection < curSection)
			lastSection = curSection;
	}

	public function beatHit()
	{
		if (lastBeat < curBeat)
			lastBeat = curBeat;
	}

	public function stepHit()
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public var isStartingSong:Bool = false;
	public var isEndingSong:Bool = false;

	public function endSong()
	{
		isEndingSong = true;

		if (FlxG.sound.music != null && FlxG.sound.music.playing)
		{
			FlxG.sound.music.volume = 0;
			FlxG.sound.music.pause();
		}

		if (Conductor.songVocals != null && Conductor.songVocals.playing)
		{
			Conductor.songVocals.volume = 0;
			Conductor.songVocals.pause();
		}

		Conductor.songPosition = FlxG.sound.music.length;
	}

	public function updateSelection(newSelection:Int = 0)
		selection = FlxMath.wrap(Math.floor(selection) + newSelection, 0, wrappableGroup.length - 1);
}

class MusicBeatSubstate extends FlxSubState implements IMusicBeat
{
	public var curBeat:Int = 0;
	public var curStep:Int = 0;
	public var curSection:Int = 0;

	public var lastBeat:Int = 0;
	public var lastStep:Int = 0;
	public var lastSection:Int = 0;

	public var selection:Int = 0;

	public var wrappableGroup:Array<Dynamic> = [];

	override public function create()
	{
		super.create();
	}

	override public function update(elapsed:Float)
	{
		updateSongContents();

		super.update(elapsed);
	}

	public function updateSongContents()
	{
		var oldStep:Int = curStep;

		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
		curBeat = Math.floor(curStep / 4);
		curSection = Math.floor(curBeat / 4);

		if (lastStep <= curStep)
		{
			lastStep = curStep;
			stepHit();
		}
		if (lastBeat <= curBeat)
		{
			lastBeat = curBeat;
			beatHit();
		}
		if (lastSection <= curSection)
		{
			lastSection = curSection;
			sectionHit();
		}
	}

	public function sectionHit() {}

	public function beatHit() {}

	public function stepHit() {}

	public function endSong() {}

	public function updateSelection(newSelection:Int = 0)
		selection = FlxMath.wrap(Math.floor(selection) + newSelection, 0, wrappableGroup.length - 1);
}
