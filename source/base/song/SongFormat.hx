package base.song;

typedef SectionBody =
{
	var time:Float; // strum time
	var index:Int; // note data
	var type:String; // note type
	var animation:String; // note animation string
	var holdLength:Float; // note sustain length
	var mustHit:Bool; // whether the player should hit the note
}

typedef CyndaSong = // no idea for a name so here's my favorite pokémon starter lol
{
	var name:String;
	var displayName:String;
	var speed:Float;
	var bpm:Int;
	//
	var notes:Array<SectionBody>;
	var events:Array<TimedEvent>; // just uses my outdated event format which I will likely change later
	//
	var player:String;
	var opponent:String;
	var spectator:String; // spectator being a fancy way to say "girlfriend"
}

typedef TimedEvent =
{
	var name:String;
	var step:Float;
	var values:Array<String>;
}

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var validScore:Bool;
}

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Int;
	var changeBPM:Bool;
	var altAnim:Bool;
}

class SongLegacy
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}
}

class SectionLegacy
{
	public var sectionNotes:Array<Dynamic> = [];

	public var lengthInSteps:Int = 16;
	public var typeOfSection:Int = 0;
	public var mustHitSection:Bool = true;

	/**
	 *	Copies the first section into the second section!
	 */
	public static var COPYCAT:Int = 0;

	public function new(lengthInSteps:Int = 16)
	{
		this.lengthInSteps = lengthInSteps;
	}
}
