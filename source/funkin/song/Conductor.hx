package funkin.song;

import flixel.FlxG;
import flixel.system.FlxSound;
import funkin.song.SongFormat.FeatherSong;

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

/**

	the Conductor class is responsible for managing song variables and song playing in general,
	not only it initializes songs, but it also calculates Beats per Second (BPM) Changes and resyncs vocal tracks
	if they are off-sync

	currently similar to the base game structure with only song playing changes
**/
class Conductor
{
	public static var bpm:Float = 100.0; // Defines the Song BPM
	public static var crochet:Float = ((60 / bpm) * 1000); // Defines the Song Beats in Milliseconds
	public static var stepCrochet:Float = crochet / 4; // Defines the Song Steps in Milliseconds
	public static var songPosition:Float; // Defines the Current Song Position
	public static var lastSongPos:Float; // Defines the Last Song Position

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];
	public static var songMusic:FlxSound; // the Instrumental Track for a Song
	public static var songVocals:FlxSound; // the Vocal Track for a Song
	public static var songRate:Float = 1; // the Song Playback Rate / Speed
	public static var canStartSong:Bool = false; // Whether or not we can begin to play the song

	public static var safeZoneOffset:Float = (OptionsAPI.getPref("Safe Frames") / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds

	public static function mapBPMChanges(song:FeatherSong):Void
	{
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.sectionNotes.length)
		{
			if (song.sectionNotes[i].bpm != curBPM)
			{
				curBPM = song.sectionNotes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			totalPos += ((60 / curBPM) * 1000 / 4) * 16;
		}
		// trace("new BPM map BUDDY " + bpmChangeMap);
	}

	public static function changeBPM(newBpm:Float):Void
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}

	public static function callVocals(name:String):Void
	{
		songMusic = new FlxSound().loadEmbedded(AssetHandler.grabAsset("Inst", SOUND, "songs/" + name));
		songVocals = new FlxSound().loadEmbedded(AssetHandler.grabAsset("Voices", SOUND, "songs/" + name));

		#if (flixel >= "5.0.0")
		songMusic.pitch = songRate;
		#end

		FlxG.sound.list.add(songMusic);

		if (songVocals != null)
		{
			#if (flixel >= "5.0.0")
			songVocals.pitch = songRate;
			#end
			FlxG.sound.list.add(songVocals);
		}
	}

	public static function playSong(name:String):Void
	{
		if (songMusic != null)
			songMusic.play();
		if (songVocals != null)
			songVocals.play();
	}

	public static function pauseSong():Void
	{
		if (songMusic != null)
			songMusic.pause();
		if (songVocals != null)
			songVocals.pause();
	}

	public static function resyncVocals():Void
	{
		if (songVocals != null)
			songVocals.pause();

		if (songMusic != null)
		{
			songMusic.play();
			songPosition = songMusic.time;
		}

		if (songVocals != null)
		{
			songVocals.time = Conductor.songPosition;
			#if (flixel >= "5.0.0")
			songVocals.pitch = songRate;
			#end
			songVocals.play();
		}
	}

	public static function stepResync():Void
	{
		if ((songMusic != null && Math.abs(songMusic.time - (songPosition)) > 20)
			|| (songVocals != null && Math.abs(songVocals.time - (songPosition)) > 20))
		{
			resyncVocals();
		}
	}

	public static function stopSong():Void
	{
		if (songMusic != null)
			songMusic.stop();
		if (songVocals != null)
			songVocals.stop();
	}
}
