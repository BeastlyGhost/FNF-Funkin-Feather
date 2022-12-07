package funkin.objects.ui.menus;

import flixel.FlxSprite;

class CheckboxThingie extends FlxSprite
{
	override public function new(x:Float, y:Float):Void
	{
		super(x, y);

		frames = AssetHandler.grabAsset('checkboxThingie', IMAGE, 'images/menus/optionsMenu');
		animation.addByPrefix('true', 'Check Box unselected', 24, false);
		animation.addByPrefix('false', 'Check Box selecting animation', 24, false);

		antialiasing = true;
		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (animation.curAnim.name == 'true')
			offset.set(17, 70);
	}
}
