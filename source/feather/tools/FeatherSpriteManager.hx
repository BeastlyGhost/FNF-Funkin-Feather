package feather.tools;

import flixel.FlxSprite;

/**
	Flixel Sprite Extension made for characters! 
**/
class FeatherSprite extends FlxSprite
{
	//
	public var animOffsets:Map<String, Array<Dynamic>>;

	public function new(x:Float = 0, y:Float = 0):Void
	{
		super(x, y);
		animOffsets = new Map<String, Array<Dynamic>>();
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		centerOffsets();
		centerOrigin();

		var daOffset:Array<Dynamic> = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
			offset.set(daOffset[0], daOffset[1]);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0):Void
		animOffsets[name] = [x, y];

	public override function destroy():Void
	{
		if (graphic != null)
			graphic.dump();
		super.destroy();
	}
}

/**
	a Sprite that follows a parent sprite
**/
class ChildSprite extends FeatherSprite
{
	public var parentSprite:FlxSprite;

	public var addX:Float = 0;
	public var addY:Float = 0;
	public var addAngle:Float = 0;
	public var addAlpha:Float = 0;

	public var copyParentAngle:Bool = false;
	public var copyParentAlpha:Bool = false;
	public var copyParentVisib:Bool = false;

	public function new(fileName:String, ?fileFolder:String, ?fileAnim:String, ?looped:Bool = false):Void
	{
		super(x, y);

		if (fileName != null)
		{
			if (fileAnim != null)
			{
				frames = AssetHelper.grabAsset(fileName, SPARROW, fileFolder);
				animation.addByPrefix('static', fileAnim, 24, looped);
				animation.play('static');
			}
			else
				loadGraphic(AssetHelper.grabAsset(fileName, IMAGE, fileFolder));
			scrollFactor.set();
		}
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// set parent sprite stuffs;
		if (parentSprite != null)
		{
			setPosition(parentSprite.x + addX, parentSprite.y + addY);
			scrollFactor.set(parentSprite.scrollFactor.x, parentSprite.scrollFactor.y);

			if (copyParentAngle)
				angle = parentSprite.angle + addAngle;

			if (copyParentAlpha)
				alpha = parentSprite.alpha * addAlpha;

			if (copyParentVisib)
				visible = parentSprite.visible;
		}
	}
}
