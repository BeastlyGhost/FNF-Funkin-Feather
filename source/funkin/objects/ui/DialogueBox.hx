package funkin.objects.ui;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

@:enum abstract BoxTextForm(String) to String
{
    var BASE = 'base';
    var PIXEL = 'pixel';
}
typedef BoxDataForm =
{
    var texture:String;
    var texturePath:String;
    var ?textForm:String;
    var ?position:Array<Float>;
    var ?animated:Bool;
    var ?framerate:Float;
    var ?size:Float;
}

typedef CharDataForm = 
{
    var texture:String;
    var texturePath:String;
    var animations:Array<CharAnimForm>;
}

typedef CharAnimForm =
{
    var anim:Null<String>;
	var animOffset:Array<Float>;
    var animDefault:Null<String>;
}

class DialogueBox extends FlxSpriteGroup
{
    public var boxData:BoxDataForm;
    public var charData:CharDataForm;

    public var textList:Array<String> = [];

    override public function new(file:String):Void
    {
        // dialogue box defaults
        boxData = {
            texture: "speech_bubble_talking",
            texturePath: "images/dialogue",
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
        var type:AssetType = (boxData.animated ? SPARROW : IMAGE);

        var diagBox:FlxSprite = new FlxSprite();
        if (type == SPARROW)
            diagBox.frames = AssetHandler.grabAsset(tex, SPARROW, boxData.texturePath)
        else
            diagBox.loadGraphic(AssetHandler.grabAsset(tex, IMAGE, boxData.texturePath));

        diagBox.screenCenter();
        diagBox.setPosition(boxData.position[0], boxData.position[1]);

        return diagBox;
    }
}
