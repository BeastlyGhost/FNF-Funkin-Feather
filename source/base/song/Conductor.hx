package base.song;

import base.song.SongFormat.SwagSong;
import flixel.FlxG;
import flixel.system.FlxSound;
import states.PlayState;

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Int;
}

/**

	the Conductor class is responsible for managing song variables and song playing in general,
	not only it initializes songs, but it also calculates Beats per Second (BPM) Changes and resyncs vocal tracks
	if they are off-sync

	currently similar to the base game structure with only song playing changes
**/
class Conductor
{
	public static var bpm:Int = 100; // Defines the Song BPM
	public static var crochet:Float = ((60 / bpm) * 1000); // Defines the Song Beats in Milliseconds
	public static var stepCrochet:Float = crochet / 4; // Defines the Song Steps in Milliseconds
	public static var songPosition:Float; // Defines the Current Song Position
	public static var lastSongPos:Float; // Defines the Last Song Position

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];
	public static var songVocals:FlxSound; // the Vocal Track for a Song
	public static var canStartSong:Bool = false; // Whether or not we can begin to play the song

	public static function mapBPMChanges(song:SwagSong)
	{
		bpmChangeMap = [];

		var curBPM:Int = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
	}

	public static function changeBPM(newBpm:Int)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}

	public static function callVocals(name:String)
	{
		AssetHandler.grabAsset("Inst", SOUND, "songs/" + name);
		songVocals = new FlxSound().loadEmbedded(AssetHandler.grabAsset("Voices", SOUND, "songs/" + name));
		FlxG.sound.list.add(songVocals);
	}

	public static function playSong(name:String)
	{
		FlxG.sound.playMusic(AssetHandler.grabAsset("Inst", SOUND, "songs/" + name));
		if (songVocals != null)
			songVocals.play();
	}

	public static function pauseSong()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.pause();
		if (songVocals != null)
			songVocals.pause();
	}

	public static function resyncVocals()
	{
		if (songVocals != null)
			songVocals.pause();

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.play();
			songPosition = FlxG.sound.music.time;
		}

		if (songVocals != null)
		{
			songVocals.time = Conductor.songPosition;
			songVocals.play();
		}
	}

	public static function stepResync()
	{
		if (FlxG.sound.music != null)
		{
			if (Math.abs(FlxG.sound.music.time - (songPosition)) > 20
				|| (songVocals != null && Math.abs(songVocals.time - (songPosition)) > 20))
			{
				resyncVocals();
			}
		}
	}

	public static function stopSong()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		if (songVocals != null)
			songVocals.stop();
	}
}
