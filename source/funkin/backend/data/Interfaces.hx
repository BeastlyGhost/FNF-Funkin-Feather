package funkin.backend.data;

/**
	Interface methods are a way to generalize similar variables and functions,
	they are used to specify the behavior of a class, not many interfaces will be
	directly used with the project, but this class will be kept for the sake of organization
	and source code abstraction in a general sense

	@BeastlyGhost
**/
class Interfaces {} // nothing, I just wanna leave the comment haha

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
