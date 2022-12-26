package funkin.objects.ui;

import flixel.text.FlxText;

enum TextType {
	SCORETEXT;
	AUTOPLAY;
}

/**
	FlxText Extension used for the user interface texts
**/
class UIText extends FlxText {
	var ui:String = OptionsAPI.getPref("UI Style").toLowerCase();
	var align:FlxTextAlign = LEFT;
	var fontName:String = "vcr";
	var textSize:Int = 20;

	public override function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, TextType:TextType):Void {
		super(X, Y, FieldWidth, '', 8, true);

		switch (TextType) {
			case SCORETEXT:
				textSize = (ui == "feather" ? 20 : 16);
				align = (ui == "feather" ? CENTER : LEFT);
			default:
				textSize = 32;
				align = CENTER;
		}

		switch (ui) {
			case "feather":
				fontName = "muff-bold";
				setFormat(AssetHelper.grabAsset(fontName, FONT, "data/fonts"), textSize, 0xFFFFFFFF, CENTER, SHADOW, 0xFF000000);
				shadowOffset.set(2, 2);
			default:
				fontName = "vcr";
				setFormat(AssetHelper.grabAsset(fontName, FONT, "data/fonts"), textSize, 0xFFFFFFFF, align, OUTLINE, 0xFF000000);
		}

		scrollFactor.set();
	}
}
