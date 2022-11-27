package base.song;

import base.song.SongFormat;
import flixel.FlxG;
import flixel.util.FlxSort;
import haxe.Json;
import objects.ui.Note;
import sys.FileSystem;

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

	public static function parseChart(dataSent:SwagSong):Array<Note>
	{
		var arrayNotes:Array<Note> = [];

		var timeBegin:Float = Sys.time();

		/*
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
		 */

		arrayNotes.sort(function(a:Note, b:Note) return a.strumTime < b.strumTime ? FlxSort.ASCENDING : a.strumTime > b.strumTime ? -FlxSort.ASCENDING : 0);

		var timeEnd:Float = Sys.time();
		trace('parsing took: ${Math.round(timeEnd - timeBegin)}s');
		return arrayNotes;
	}
}
