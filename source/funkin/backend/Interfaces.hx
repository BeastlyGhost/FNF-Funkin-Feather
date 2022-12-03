package funkin.backend;

/**
	Handles variales used on the `MusicState` class
**/
interface MusicInterface
{
	public var curBeat:Int; // Defines the Current Beat on the Current Song
	public var curStep:Int; // Defines the Current Step on the Current Song
	public var curSection:Int; // Defines the Current Section on the Current Song
	public function beatHit():Void; // Decides what to do when a Beat is hit
	public function sectionHit():Void; // Decides what to do when a Section is hit
	public function stepHit():Void; // Decides what to do when a Step is hit, also updates beats
	public function endSong():Void; // a Function to decide what to do when a song ends
}
