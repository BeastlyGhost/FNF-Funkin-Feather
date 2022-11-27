package objects;

import base.utils.FeatherUtils.FeatherSprite;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import states.PlayState;

class Stage extends FlxTypedGroup<FlxBasic>
{
	public var curStage:String;

	public var cameraZoom:Float = 1.05;

	public function new()
	{
		super();

		if (curStage == null)
			curStage = "stage";
	}

	public function setStage(curStage:String)
	{
		switch (curStage)
		{
			default:
				cameraZoom = 0.9;

				var bg:FlxSprite = new FlxSprite(-600, -200);
				bg.loadGraphic(AssetHandler.grabAsset('stageback', IMAGE, "data/stages/stage/images"));
				bg.scrollFactor.set(0.9, 0.9);
				add(bg);

				var stageFront:FlxSprite = new FlxSprite(-650, 600);
				stageFront.loadGraphic(AssetHandler.grabAsset('stagefront', IMAGE, "data/stages/stage/images"));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.updateHitbox();
				add(stageFront);

				var stageCurtains:FlxSprite = new FlxSprite(-500, -300);
				stageCurtains.loadGraphic(AssetHandler.grabAsset('stagecurtains', IMAGE, "data/stages/stage/images"));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.updateHitbox();
				add(stageCurtains);
		}
	}
}
