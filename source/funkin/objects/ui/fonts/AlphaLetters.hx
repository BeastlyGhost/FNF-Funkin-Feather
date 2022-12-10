package funkin.objects.ui.fonts;

typedef Letter =
{
	var anim:Null<String>;
	var normalOffset:Array<Float>;
	var boldOffset:Array<Float>;
}

class AlphaLetters
{
	public static var letterMap:Map<String, Null<Letter>> = [
		"a" => null, "b" => null, "c" => null, "d" => null, "e" => null,
		"f" => null, "g" => null, "h" => null, "i" => null, "j" => null,
		"k" => null, "l" => null, "m" => null, "n" => null, "o" => null,
		"p" => null, "q" => null, "r" => null, "s" => null, "t" => null,
		"u" => null, "v" => null, "w" => null, "x" => null, "y" => null,
		"z" => null];
}