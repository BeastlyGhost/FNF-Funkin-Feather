package funkin.objects.ui.notes;

import flixel.FlxG;
import flixel.util.FlxColor;
import funkin.states.PlayState;

class NoteSplash extends FeatherSprite
{
	private var uiStyle:String = OptionsAPI.getPref("User Interface Style");

	public var index:Int;

	public var offsetX:Int = 0;
	public var offsetY:Int = 0;

	public var colorByIndex:Bool = false;

	public function new(x:Float, y:Float, index:Int = 0):Void
	{
		super(x, y);

		this.index = index;
		ID = index;

		switch (uiStyle)
		{
			case "Feather":
				loadGraphic(AssetHelper.grabAsset("featherSplashes", IMAGE, "data/notes/default"), true, 500, 500);
				for (i in 0...2)
					animation.add('impact$i', [0, 1, 2, 3, 4, 5, 6, 7, 8], 20, false);
				setGraphicSize(Std.int(width * 0.4));
				offsetX = 170;
				offsetY = 170;
				colorByIndex = true;
			default:
				frames = AssetHelper.grabAsset("noteSplashes", SPARROW, "data/notes/default");
				for (i in 0...2)
					animation.addByPrefix('impact$i', 'note impact $i ${BabyArrow.colors[ID]}', 24, false);
				offsetX = 60;
				offsetY = 30;
				colorByIndex = false;
		}

		setupNoteSplash(x, y, index);
	}

	public function setupNoteSplash(x:Float, y:Float, index:Int = 0):Void
	{
		this.index = index;
		ID = index;

		if (colorByIndex)
			color = BabyArrow.colorPresets.get(PlayState.assetSkin)[index];

		setPosition(x, y);
		animation.play('impact${FlxG.random.int(0, 1)}', true);
		updateHitbox();
		offset.set(offsetX, offsetY);
	}

	override public function update(elapsed:Float):Void
	{
		if (animation.curAnim != null && animation.curAnim.finished)
			kill();

		super.update(elapsed);
	}
}
