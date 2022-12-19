package funkin.objects.ui.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;

class WeekItem extends FlxSpriteGroup
{
	var itemY:Float = 0;
	var sprite:FlxSprite;
	var flashingVal:Int = 0;

	public function new(x:Float, y:Float, imageName:String = 'week0'):Void
	{
		super(x, y);
		sprite = new FlxSprite().loadGraphic(AssetHelper.grabAsset(imageName, IMAGE, 'images/menus/storyMenu/weeks'));
		add(sprite);
	}

	var spriteActive:Bool = false;

	public function select():Void
		spriteActive = true;

	var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		y = FlxMath.lerp(y, (itemY * 120) + 480, 0.17);

		if (spriteActive)
			flashingVal += 1;

		if (flashingVal % fakeFramerate >= Math.floor(fakeFramerate / 2))
			sprite.color = 0xFF33FFFF;
		else
			sprite.color = 0xFFFFFFFF;
	}
}
