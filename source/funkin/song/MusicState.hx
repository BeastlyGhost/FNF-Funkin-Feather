package funkin.song;

import funkin.states.ScriptableState;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import funkin.backend.data.Interfaces.IMusicBeat;
import funkin.backend.Transition;
import funkin.song.Conductor.BPMChangeEvent;
import funkin.states.PlayState;

/**
	Music State is a simple class in which doesn't extend anything
	it is meant only for storing useful functions
**/
class MusicState
{
	public static function boundFramerate(input:Float):Float
		return input * (60 / FlxG.drawFramerate);

	public static function switchState(state:FlxState):Void
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

	public static function resetState(?skipTransition:Bool):Void
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
	State used by most classes which use tools related to game songs
**/
class MusicBeatState extends ScriptableState implements IMusicBeat
{
	public var curBeat:Int = 0;
	public var curStep:Int = 0;
	public var curSection:Int = 0;

	public var lastBeat:Int = 0;
	public var lastStep:Int = 0;
	public var lastSection:Int = 0;

	public var musicInter:IMusicBeat;

	override public function create():Void
	{
		// clear assets cache
		AssetHandler.clear(true, true);

		// play the transition if we are allowed to
		if (!FlxTransitionableState.skipNextTransOut)
			Transition.start(0.3, false, Fade, FlxEase.linear);

		super.create();
	}

	override public function update(elapsed:Float):Void
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

	override function closeSubState():Void
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

	public function updateTime():Void
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
		}
	}

	public function sectionHit():Void
	{
		// trace('Section $curSection - Prev $lastSection');
		if (lastSection < curSection)
			lastSection = curSection;
	}

	public function beatHit():Void
	{
		if (curBeat % 4 == 0)
			sectionHit();

		if (lastBeat < curBeat)
			lastBeat = curBeat;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public var isStartingSong:Bool = false;
	public var isEndingSong:Bool = false;

	public function endSong():Void {}
}

class MusicBeatSubstate extends ScriptableSubstate implements IMusicBeat
{
	public var curBeat:Int = 0;
	public var curStep:Int = 0;
	public var curSection:Int = 0;

	public var lastBeat:Int = 0;
	public var lastStep:Int = 0;
	public var lastSection:Int = 0;

	override public function update(elapsed:Float):Void
	{
		updateTime();

		super.update(elapsed);
	}

	public function updateTime():Void
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

	public function sectionHit():Void
	{
		if (lastSection < curSection)
			lastSection = curSection;
	}

	public function beatHit():Void
	{
		if (lastBeat < curBeat)
			lastBeat = curBeat;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function endSong():Void {}
}
