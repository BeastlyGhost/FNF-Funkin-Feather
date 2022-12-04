package funkin.backend.data;

typedef MainMenuData =
{
	var bg:String;
	var flash:String;
	var bgFolder:String;
	var flashFolder:String;
	var flashColor:Int;
	var list:Array<String>;
	var listY:Float;
	var listSpacing:Float;
}

typedef TitleData =
{
	var bg:String;
	var gf:String;
	var ng:String;
	var bgSize:Float;
	var bgFolder:String;
	var gfFolder:String;
	var ngFolder:String;
	var bgAntialias:Bool;
	var gfAntialias:Bool;
	var ngAntialias:Bool;
	var randomText:Array<Array<String>>;
	var stepText:Array<IntroData>;
}

typedef IntroData =
{
	var steps:Array<Int>;
	var lines:Array<String>;
	var ngVisible:Bool;
	var showRandom:Bool;
	var func:String;
}
