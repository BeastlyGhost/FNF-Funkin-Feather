package funkin.objects.ui;

import flixel.text.FlxText;

/**
	FlxText Extension used for the user interface texts
**/
class UIText extends FlxText
{
	public override function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true):Void
	{
		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);

		var fontName:String = "vcr";

		switch (OptionsAPI.getPref("User Interface Style"))
		{
			case "Feather":
				fontName = "muff-bold";
				setFormat(AssetHelper.grabAsset(fontName, FONT, "data/fonts"), 20, 0xFFFFFFFF, CENTER, SHADOW, 0xFF000000);
				shadowOffset.set(2, 2);
			default:
				fontName = "vcr";
				setFormat(AssetHelper.grabAsset(fontName, FONT, "data/fonts"), 16, 0xFFFFFFFF, RIGHT, OUTLINE, 0xFF000000);
		}

		scrollFactor.set();
	}
}
