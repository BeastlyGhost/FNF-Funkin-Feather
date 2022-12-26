package fnf.song;

import feather.assets.AssetGroup;
import flixel.util.FlxColor;
import sys.FileSystem;

enum WeekAttribute {
	LOCKED;
	HIDE_STORY;
	HIDE_FREEPLAY;
}

/**
	Main Week Format
**/
typedef WeekForm = {
	var weekImage:String;
	var storyName:String;
	var songs:Array<WeekSongForm>;
	var characters:Array<String>;
	var difficulties:Array<String>;
	var attributes:Array<WeekAttribute>;
}

/**
	Week Song Format
**/
typedef WeekSongForm = {
	var name:String;
	var character:String;
	var colors:Array<Int>; // for freeplay
}

/**
	Freeplay Song Format
**/
typedef SongListForm = {
	var name:String;
	var ?group:String; // might use for separators later??
	var week:Int;
	var character:String;
	var diffs:Array<String>;
	var color:FlxColor;
}

class SongManager {
	public static var defaultDiffs:Array<String> = ['EASY', 'NORMAL', 'HARD'];

	/**
		=========== STORY SONGS ===========
	**/
	@:isVar public static var weekList(get, default):Array<WeekForm> = [];

	public static function get_weekList():Array<WeekForm> {
		// clear the week list in case it's not empty already
		weekList = [];

		return weekList;
	}

	/**
		=========== FREEPLAY SONGS ===========
	**/
	@:isVar public static var songList(get, default):Array<SongListForm> = [];

	public static function get_songList():Array<SongListForm> {
		// clear the song list in case it's not empty already
		songList = [];

		var songsMap:Map<String, Array<String>> = [];

		// loop through every asset group
		for (i in 0...AssetGroup.allGroups.length) {
			var group:String = AssetGroup.allGroups[i];
			if (group == null)
				break;

			if (FileSystem.exists('assets/$group/data/songs')) {
				var song:Array<String> = FileSystem.readDirectory('assets/$group/data/songs');

				// add it to our songs list
				if (!song.contains('.'))
					songsMap.set(group, song);
				// trace('Group: $group - Songs: ${songs.get(group)}');
			}
		}

		for (group => songs in songsMap) {
			if (group == null)
				group = '';

			if (songs != null && songs.length > 0) {
				for (i in songs) {
					songList.push({
						name: i,
						group: group,
						week: 0, // change this to the ACTUAL week number later...
						character: 'bf',
						diffs: defaultDiffs,
						color: 0xFFDCDCDC
					});
				}
			}
		}

		return songList;
	}
}
