package funkin.objects.ui;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

@:enum abstract BoxTextForm(String) to String
{
	var BASE = 'default';
	var PIXEL = 'pixel';
}

typedef BoxForm =
{
	var texture:String;
	var texturePath:String;
	var ?textForm:String;
	var ?position:Array<Float>;
	var ?animated:Bool;
	var ?framerate:Float;
	var ?size:Float;
}

typedef CharForm =
{
	var texture:String;
	var texturePath:String;
	var animations:Array<AnimForm>;
}

typedef AnimForm =
{
	var anim:Null<String>;
	var animOffset:Array<Float>;
	var animDefault:Null<String>;
}

class DialogueBox extends FlxSpriteGroup
{
	public var boxData:BoxForm;
	public var charData:CharForm;

	public var textList:Array<String> = [];

	public override function new(file:String):Void
	{
		// dialogue box defaults
		boxData = {
			texture: "speech_bubble_talking",
			texturePath: "images/dialogue/boxes",
			animated: true,
			textForm: BASE,
			position: [0, 0],
			framerate: 24,
			size: 1
		};

		initBox(boxData.texture, file);

		super();
	}

	public function initBox(tex:String, file:String):FlxSprite
	{
		var texType:AssetType = (boxData.animated ? SPARROW : IMAGE);

		var diagBox:FlxSprite = new FlxSprite();
		if (texType == SPARROW)
			diagBox.frames = AssetHelper.grabAsset(tex, SPARROW, boxData.texturePath)
		else
			diagBox.loadGraphic(AssetHelper.grabAsset(tex, IMAGE, boxData.texturePath));

		diagBox.screenCenter();
		diagBox.setPosition(boxData.position[0], boxData.position[1]);

		return diagBox;
	}
}
