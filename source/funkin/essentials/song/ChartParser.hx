package funkin.essentials.song;

import flixel.FlxG;
import flixel.util.FlxSort;
import funkin.objects.ui.notes.Note;
import funkin.essentials.song.SongFormat;
import haxe.Json;

enum DataFormat
{
	VANILLA; // Base Game
	FEATHER; // Custom Format
}

/**
	Chart Parser class for initializing song charts and notes
**/
class ChartParser
{
	public static var chartDataType:DataFormat = FEATHER;

	public static var noteList:Array<Note> = [];
	public static var eventList:Array<TimedEvent> = [];

	public static function loadChartData(songName:String, songDiff:Int):FeatherSong
	{
		var timeBegin:Float = Sys.time();

		var songDiff:String = SongManager.defaultDiffs[songDiff];

		if (songDiff.toLowerCase() == "normal")
			songDiff = '';
		else
			songDiff = '-${songDiff.toLowerCase()}';

		var dataSong = AssetHelper.grabAsset(songName + songDiff, JSON, 'data/songs/' + songName);

		var funkinSong:SwagSong = cast Json.parse(dataSong).song;
		var featherSong:FeatherSong = cast Json.parse(dataSong).song;

		if (funkinSong.notes != null)
			chartDataType = VANILLA;

		if (featherSong.author == null || featherSong.author.length < 1)
			featherSong.author = '???';

		if (chartDataType != null && chartDataType == VANILLA)
		{
			if (funkinSong.gfVersion == null)
			{
				if (funkinSong.player3 != null)
					funkinSong.gfVersion = funkinSong.player3;
				else
					funkinSong.gfVersion = 'gf';
			}

			if (funkinSong.songAuthor == null || funkinSong.songAuthor.length < 1)
				funkinSong.songAuthor = '???';

			// get the FNF Chart Style and convert it to the new format
			featherSong = {
				name: songName,
				internalName: funkinSong.song,
				author: funkinSong.songAuthor,
				speed: funkinSong.speed,
				bpm: funkinSong.bpm,
				sectionNotes: [],
				sectionEvents: [],
				player: funkinSong.player1,
				opponent: funkinSong.player2,
				crowd: funkinSong.gfVersion, // while the original chart format didn't have it, most engines do.
				stage: funkinSong.stage,
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

					var sectionIndex:Int = 0;
					var daMustHit:Bool = section.mustHitSection;
					if (songNotes[1] > 3)
						daMustHit = !section.mustHitSection;

					sectionIndex = (daMustHit ? 1 : 0);

					if (section.altAnim)
						songNotes[4] = '-alt';

					if (songNotes[1] >= 0) // if the note data is valid (AKA not a old psych event)
					{
						// create a body for our section note
						var myNote:SectionBody = {
							time: daStrumTime,
							index: daNoteData,
							holdLength: daHoldLength,
							hitIndex: sectionIndex,
						}

						if (daNoteType != null && daNoteType != 'default')
							myNote.type = daNoteType;
						if (songNotes[4] != null && songNotes[4] != '')
							myNote.animation = songNotes[4];

						// push the newly converted note to the notes array
						featherSong.sectionNotes.push(myNote);
					}
				}
			}
		}

		var timeEnd:Float = Sys.time();
		trace('parsing took: ${timeEnd - timeBegin}s');
		return featherSong;
	}

	public static function loadChartNotes(song:FeatherSong):FeatherSong
	{
		noteList = [];
		eventList = [];

		for (note in song.sectionNotes)
		{
			var oldNote:Note;
			if (noteList.length > 0)
				oldNote = noteList[Std.int(noteList.length - 1)];
			else
				oldNote = null;

			var swagNote:Note = new Note(note.time, note.index, note.type, false, oldNote);
			swagNote.speed = song.speed;
			swagNote.sustainLength = note.holdLength;
			swagNote.typeData.type = note.type;
			swagNote.scrollFactor.set(0, 0);
			noteList.push(swagNote);

			if (note.holdLength > 0)
			{
				var holdLength:Int = Math.floor(swagNote.sustainLength / Conductor.stepCrochet);

				for (holdNote in 0...holdLength)
				{
					oldNote = noteList[Std.int(noteList.length - 1)];

					var sustainNote:Note = new Note(note.time + (Conductor.stepCrochet * holdNote) + Conductor.stepCrochet, note.index, note.type, true,
						oldNote);
					sustainNote.scrollFactor.set();
					noteList.push(sustainNote);

					sustainNote.noteData.mustPress = (note.hitIndex == 1);
				}
			}

			swagNote.noteData.mustPress = (note.hitIndex == 1);
		}

		noteList.sort(function(a:Note, b:Note):Int return FlxSort.byValues(FlxSort.ASCENDING, a.step, b.step));

		// events
		if (song.sectionEvents.length > 0)
		{
			for (i in 0...song.sectionEvents.length)
			{
				var newEvent:TimedEvent = cast {
					name: song.sectionEvents[i].name,
					step: song.sectionEvents[i].step,
					values: song.sectionEvents[i].values,
				};
				eventList.push(newEvent);
				eventList.sort(function(a:TimedEvent, b:TimedEvent):Int return FlxSort.byValues(FlxSort.ASCENDING, a.step, b.step));
			}
		}

		// TODO: Camera Events
		return song;
	}

	public static function parseChartLegacy(dataSent:SwagSong):Array<Note>
	{
		var arrayNotes:Array<Note> = [];

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

				var swagNote:Note = new Note(daStrumTime, daNoteData, 'default', false, oldNote);
				swagNote.speed = dataSent.speed;
				swagNote.sustainLength = songNotes[2];
				swagNote.typeData.type = songNotes[3];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				arrayNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = arrayNotes[Std.int(arrayNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, 'default', true,
						oldNote);
					sustainNote.scrollFactor.set();
					arrayNotes.push(sustainNote);

					sustainNote.noteData.mustPress = gottaHitNote;
				}

				swagNote.noteData.mustPress = gottaHitNote;
			}
		}

		arrayNotes.sort(function(a:Note, b:Note):Int return FlxSort.byValues(FlxSort.ASCENDING, a.step, b.step));
		return arrayNotes;
	}
}
