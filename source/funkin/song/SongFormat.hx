package funkin.song;

/**
	-- @BeastlyGhost --

	this section body is used as a replacement for "SwagSection",
	I tried to make it as readable as possible when exporting to JSONs
**/
typedef SectionBody =
{
	var time:Float; // strum time
	var index:Int; // note data
	var ?type:String; // note type ("default" by default)
	var ?animation:String; // note animation string (null by default)
	var holdLength:Float; // note sustain length
	var cameraPoint:String; // where should the camera point to
	var ?bpm:Float;
}

/**
	-- @BeastlyGhost --

	`FeatherSong` is my custom made chart format for the game,
	I made it mainly because I was having issues parsing the base one,
	but also just because I thought i could make something cleaner and more readable
**/
typedef FeatherSong =
{
	var name:String;
	var internalName:String;
	var author:String;
	var speed:Float;
	var bpm:Float;
	//
	var sectionNotes:Array<SectionBody>;
	var sectionEvents:Array<TimedEvent>;
	//
	var player:String;
	var opponent:String;
	var crowd:String; // fancy way to say "girlfriend"
	var stage:String;
}

/**
	-- @BeastlyGhost --

	quick and dirty Song Event format,
	those events trigger every time the `step` that the event needs is reached on a song
**/
typedef TimedEvent =
{
	var name:String;
	var step:Float;
	var values:Array<String>;
}

/**
	Friday Night Funkin' 0.2.7.1/0.2.8 Song Format
**/
typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var player3:String;
	var gfVersion:String;
	var songAuthor:String;
	var stage:String;
	var validScore:Bool;
}

/**
	Friday Night Funkin' 0.2.7.1/0.2.8 Section Format
**/
typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Int;
	var changeBPM:Bool;
	var altAnim:Bool;
	var gfSection:Bool;
}
