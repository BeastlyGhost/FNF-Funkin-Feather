package funkin.backend.data;

enum WeekAttribute
{
	LOCKED;
	HIDE_STORY;
	HIDE_FREEPLAY;
}

/**
	Main Week Format
**/
typedef WeekForm =
{
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
typedef WeekSongForm =
{
	var name:String;
	var character:String;
	var colors:Array<Int>; // for freeplay
}

/**
	Freeplay Song Format
**/
typedef SongListForm =
{
	var name:String;
	var week:Int;
	var character:String;
	var diffs:Array<String>;
	var color:Int;
}

class SongManager
{
	public static var defaultDiffs:Array<String> = ['EASY', 'NORMAL', 'HARD'];

	/**
		=========== STORY SONGS ===========
	**/
	@:isVar public static var weekList(get, default):Array<WeekForm> = [];

	public static function get_weekList():Array<WeekForm>
	{
		// clear the week list in case it's not empty already
		weekList = [];

		return weekList;
	}

	/**
		=========== FREEPLAY SONGS ===========
	**/
	@:isVar public static var songList(get, default):Array<SongListForm> = [];

	public static function get_songList():Array<SongListForm>
	{
		// clear the song list in case it's not empty already
		songList = [];

		var songs:Array<String> = [];

		for (folder in sys.FileSystem.readDirectory('assets/songs'))
			if (!folder.contains('.'))
				songs.push(folder);

		for (i in 0...songs.length)
		{
			songList.push({
				name: songs[i],
				week: 0, // change this to the ACTUAL week number later...
				character: 'bf',
				diffs: defaultDiffs,
				color: -1
			});
		}

		return songList;
	}
}
