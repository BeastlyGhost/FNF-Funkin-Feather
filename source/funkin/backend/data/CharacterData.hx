package funkin.backend.data;

enum CharacterOrigin
{
	FUNKIN_FEATHER;
	FOREVER_FEATHER;
	FUNKIN_COCOA;
	PSYCH_ENGINE;
}

typedef PsychCharFile =
{
	var animations:Array<PsychAnimsArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;
	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
}

typedef PsychAnimsArray =
{
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}
