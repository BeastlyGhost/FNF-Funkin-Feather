package funkin.song;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import funkin.backend.Interfaces.MusicInterface;
import funkin.backend.Transition;
import funkin.song.Conductor.BPMChangeEvent;
import funkin.states.PlayState;

/**
	Music State is a simple class in which doesn't extend anything
	it is meant only for storing useful functions

	however, in the HX file, we also keep `MusicBeatState` and `MusicBeatSubstate` 
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
				Main.currentState = Type.getClass(state);
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

	public static function resetState(?skipTransition:Bool)
	{
		if (!skipTransition)
		{
			Transition.start(0.3, true, Fade, FlxEase.linear, function()
			{
				FlxG.resetState();
			});
			return;
		}
		else
			FlxG.resetState();
	}
}

/**
	a State that is widely used by the other game states
	it contains useful tools for song control that can be used by every other state
**/
class MusicBeatState extends FlxUIState implements MusicInterface
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
		AssetHandler.clear(true, true);

		// play the transition if we are allowed to
		if (!FlxTransitionableState.skipNextTransOut)
			Transition.start(0.3, false, Fade, FlxEase.linear);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (Conductor.songMusic != null)
			Conductor.songMusic.onComplete = endSong;

		updateTime();

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

		FlxTimer.globalManager.forEach(function(tmr:FlxTimer)
		{
			if (!tmr.finished)
				tmr.active = true;
		});

		FlxTween.globalManager.forEach(function(twn:FlxTween)
		{
			if (!twn.finished)
				twn.active = true;
		});

		// clear assets cache
		AssetHandler.clear(true, false);

		super.closeSubState();
	}

	public function updateTime()
	{
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

		curBeat = Math.floor(curStep / 4);
		curSection = Math.floor(curBeat / 4);

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
		Conductor.songPosition = Conductor.songMusic.length;

		if (Conductor.songMusic != null && Conductor.songMusic.playing)
		{
			Conductor.songMusic.volume = 0;
			Conductor.songMusic.pause();
		}

		if (Conductor.songVocals != null && Conductor.songVocals.playing)
		{
			Conductor.songVocals.volume = 0;
			Conductor.songVocals.pause();
		}
	}

	public function updateSelection(newSelection:Int = 0)
		selection = FlxMath.wrap(Math.floor(selection) + newSelection, 0, wrappableGroup.length - 1);
}

class MusicBeatSubstate extends FlxSubState implements MusicInterface
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
		updateTime();

		super.update(elapsed);
	}

	public function updateTime()
	{
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

		curBeat = Math.floor(curStep / 4);
		curSection = Math.floor(curBeat / 4);
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

	public function endSong() {}

	public function updateSelection(newSelection:Int = 0)
		selection = FlxMath.wrap(Math.floor(selection) + newSelection, 0, wrappableGroup.length - 1);
}
