package funkin.objects.ui;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
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

	public var character:String = 'bf';
	public var suffix:String = '';

	public function new(character:String = 'bf', flip:Bool = false)
	{
		super();

		setIcon(character, flip);
	}

	public dynamic function updateFrame(health:Float)
	{
		if (graphic == null)
			return;

		if (health < 20)
			animation.curAnim.curFrame = 1;
		else
			animation.curAnim.curFrame = 0;
	}

	public function setIcon(char:String, shouldBeFlipped:Bool)
	{
		var iconAsset:FlxGraphic = AssetHandler.grabAsset('$char/icon$suffix', IMAGE, 'data/characters');
		var iconWidth:Int = 1;

		if (!FileSystem.exists(AssetHandler.grabAsset('$char/icon$suffix', IMAGE, 'data/characters')))
		{
			if (char.contains('-'))
				char = char.substring(0, char.indexOf('-'));
		}

		if (iconAsset == null)
			return;

		loadGraphic(iconAsset); // get file size

		// icons with endless frames;
		iconWidth = Std.int(iconAsset.width / 150) - 1;
		iconWidth = iconWidth + 1;

		loadGraphic(iconAsset, true, Std.int(iconAsset.width / iconWidth), iconAsset.height); // then load it

		initialWidth = width;
		initialHeight = height;
		antialiasing = true;

		animation.add('icon', [for (i in 0...frames.frames.length) i], 0, false, shouldBeFlipped);
		animation.play('icon');
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (parentSprite != null)
		{
			setPosition(parentSprite.x + parentSprite.width + 10, parentSprite.y - 30);
			scrollFactor.set(parentSprite.scrollFactor.x, parentSprite.scrollFactor.y);
		}
	}
}
