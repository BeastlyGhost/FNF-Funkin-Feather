package funkin.objects.ui;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import sys.FileSystem;

/**
	the Icon class handles the little icons that appear bouncing on the User Interface,
	they often show up following the Health Bar
**/
class Icon extends FlxSprite
{
	public var parentSprite:FlxSprite;
	public var initialWidth:Float = 0;
	public var initialHeight:Float = 0;

	public var shouldBop:Bool = true;

	public var character:String = 'bf';
	public var suffix:String = '';

	public function new(character:String = 'bf', flip:Bool = false):Void
	{
		super();

		setIcon(character, flip);
	}

	public function doBops(onUpdate:Bool = false)
	{
		if (!shouldBop)
			return;

		// TODO: replace this with customizable one later
		if (onUpdate)
			setGraphicSize(Std.int(FlxMath.lerp(150, width, 0.85)));
		else
			setGraphicSize(Std.int(width + 30));

		updateHitbox();
	}

	public dynamic function updateFrame(health:Float):Void
	{
		if (graphic != null)
		{
			animation.curAnim.curFrame = 0;

			if (frames != null)
			{
				if (health < 20)
					animation.curAnim.curFrame = 1;
			}
		}
	}

	public function setIcon(char:String, beFlipped:Bool):Void
	{
		var stringTrim:String = char;
		if (stringTrim.contains('-'))
			stringTrim = stringTrim.substring(0, stringTrim.indexOf('-'));

		if (!FileSystem.exists(AssetHandler.grabAsset('$char/icon$suffix', IMAGE, 'data/characters')))
		{
			if (char != stringTrim)
				char = stringTrim;
			else
				char = 'placeholder';
		}

		var iconAsset:FlxGraphic = AssetHandler.grabAsset('$char/icon$suffix', IMAGE, 'data/characters');

		loadGraphic(iconAsset); // get file size

		// icons with endless frames;
		var iconWidth:Int = Std.int(iconAsset.width / 150) - 1;
		iconWidth = iconWidth + 1;

		loadGraphic(iconAsset, true, Std.int(iconAsset.width / iconWidth), iconAsset.height); // then load it

		initialWidth = width;
		initialHeight = height;
		antialiasing = true;

		animation.add('icon', [for (i in 0...frames.frames.length) i], 0, false, beFlipped);
		animation.play('icon');
		scrollFactor.set();
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (frames != null && parentSprite != null)
		{
			setPosition(parentSprite.x + parentSprite.width + 10, parentSprite.y - 30);
			scrollFactor.set(parentSprite.scrollFactor.x, parentSprite.scrollFactor.y);
		}
	}
}
