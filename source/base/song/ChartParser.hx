package base.song;

import base.song.SongFormat;
import flixel.FlxG;
import flixel.util.FlxSort;
import haxe.Json;
import objects.ui.Note;
import sys.FileSystem;

enum DataFormat
{
	BASE;
	PSYCH;
	FEATHER;
}

class ChartParser
{
	public static var difficultyMap:Map<Int, String> = [0 => "-easy", 1 => "", 2 => "-hard",];

	public static function loadSong(songName:String, diff:Int):SwagSong
	{
		var dataSong = AssetHandler.grabAsset(songName + difficultyMap.get(diff), JSON, 'songs/' + songName);

		var song:SwagSong = Json.parse(dataSong).song;
		song.validScore = true;

		return song;
	}

	public static function loadChartData(songName:String, songDiff:Int)
	{
		var timeBegin:Float = Sys.time();
		var dataSong = AssetHandler.grabAsset(songName + difficultyMap.get(songDiff), JSON, 'songs/' + songName);
		var funkinSong:SwagSong = cast Json.parse(dataSong).song;

		if (funkinSong.gfVersion == null)
		{
			if (funkinSong.player3 != null)
				funkinSong.gfVersion = funkinSong.player3;
			else
				funkinSong.gfVersion = 'gf';
		}

		// get the FNF Chart Style and convert it to the new format
		var cyndaSong:CyndaSong = {
			name: songName,
			internalName: funkinSong.song,
			speed: funkinSong.speed,
			bpm: funkinSong.bpm,
			sectionNotes: [],
			sectionEvents: [],
			player: funkinSong.player1,
			opponent: funkinSong.player2,
			crowd: funkinSong.gfVersion, // while the original chart format didn't have it, most engines do.
		};

		// with that out of the way, let's convert the notes!
		for (section in funkinSong.notes)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var daHoldLength:Float = songNotes[2];
				var daNoteType:String = 'default';

				if (Std.isOfType(songNotes[3], String))
				{
					// psych conversion
					switch (songNotes[3])
					{
						case "Hurt Note":
							songNotes[3] = 'mine';
						case "Hey!":
							songNotes[3] = 'default';
							songNotes[5] = 'hey'; // animation
						case 'Alt Animation':
							songNotes[3] = 'default';
							songNotes[4] = '-alt'; // animation string
						case "GF Sing":
							songNotes[3] = 'default';
						default:
							songNotes[3] = 'default';
					}
					daNoteType = songNotes[3];
				}

				if (songNotes[1] >= 0) // if the note data is valid (AKA not a old psych event)
				{
					// create a body for our section note
					var myNote:SectionBody = {
						time: daStrumTime,
						index: daNoteData,
						holdLength: daHoldLength,
						cameraPoint: section.mustHitSection ? "player" : "opponent",
					}

					if (daNoteType != null && daNoteType != 'default')
						myNote.type = daNoteType;
					if (songNotes[4] != null && songNotes[4] != '')
						myNote.animation = songNotes[4];

					// push the newly converted note to the notes array
					cyndaSong.sectionNotes.push(myNote);
				}
			}
		}

		// events
		var timedEvents:Array<TimedEvent> = [];

		if (cyndaSong.sectionEvents.length > 0)
		{
			for (i in 0...cyndaSong.sectionEvents.length)
			{
				var newEvent:TimedEvent = cast {
					name: cyndaSong.sectionEvents[i].name,
					step: cyndaSong.sectionEvents[i].step,
					values: cyndaSong.sectionEvents[i].values,
					/*colors: cyndaSong.sectionEvents[2][1],*/
				};
				timedEvents.push(newEvent);

				if (cyndaSong.sectionEvents.length > 1) // no need to sort if there's a single one or none
					timedEvents.sort(function(a:TimedEvent, b:TimedEvent):Int return FlxSort.byValues(FlxSort.ASCENDING, a.step, b.step));
			}
		}

		cyndaSong.sectionNotes.sort(function(a:SectionBody, b:SectionBody):Int return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time));

		var timeEnd:Float = Sys.time();
		trace('parsing took: ${timeEnd - timeBegin}s');
		return cyndaSong;
	}

	public static function loadChartNotes(song:CyndaSong)
	{
		var dunces:Array<Note> = [];

		for (note in song.sectionNotes)
		{
			var oldNote:Note;
			if (dunces.length > 0)
				oldNote = dunces[Std.int(dunces.length - 1)];
			else
				oldNote = null;

			var swagNote:Note = new Note(note.time, note.index, note.type, oldNote);
			swagNote.speed = song.speed;
			swagNote.sustainLength = note.holdLength;
			swagNote.type = note.type;
			swagNote.scrollFactor.set(0, 0);

			var susLength:Float = swagNote.sustainLength;

			susLength = susLength / Conductor.stepCrochet;
			dunces.push(swagNote);

			for (susNote in 0...Math.floor(susLength))
			{
				oldNote = dunces[Std.int(dunces.length - 1)];

				var sustainNote:Note = new Note(note.time + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, note.index, note.type, oldNote, true);
				sustainNote.scrollFactor.set();
				sustainNote.mustPress = note.cameraPoint == "bf";
				dunces.push(sustainNote);

				if (sustainNote.mustPress)
					sustainNote.x += FlxG.width / 2; // general offset
			}

			swagNote.mustPress = note.cameraPoint == "bf";

			if (swagNote.mustPress)
				swagNote.x += FlxG.width / 2; // general offset
		}

		dunces.sort(function(a:Note, b:Note):Int return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime));
		return dunces;
	}

	public static function parseChartLegacy(dataSent:SwagSong):Array<Note>
	{
		var arrayNotes:Array<Note> = [];

		var timeBegin:Float = Sys.time();

		for (section in dataSent.notes)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if (arrayNotes.length > 0)
					oldNote = arrayNotes[Std.int(arrayNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, 'default', oldNote);
				swagNote.speed = dataSent.speed;
				swagNote.sustainLength = songNotes[2];
				swagNote.type = songNotes[3];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				arrayNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = arrayNotes[Std.int(arrayNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, 'default', oldNote,
						true);
					sustainNote.scrollFactor.set();
					arrayNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;
				}

				swagNote.mustPress = gottaHitNote;
			}
		}

		arrayNotes.sort(function(a:Note, b:Note) return a.strumTime < b.strumTime ? FlxSort.ASCENDING : a.strumTime > b.strumTime ? -FlxSort.ASCENDING : 0);

		var timeEnd:Float = Sys.time();
		trace('parsing took: ${Math.round(timeEnd - timeBegin)}s');
		return arrayNotes;
	}
}
