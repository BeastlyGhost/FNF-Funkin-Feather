package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

/**
	Starting Class for the game
	used to set up useful functions and variables for the main game!
**/
class Start extends FlxState
{
	override public function create():Void
	{
		super.create();

		FlxG.fixedTimestep = true;
		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = false;

		triggerSplash(Main.game.skipSplash);
	}

	function triggerSplash(skip:Bool):Void
	{
		if (skip)
			return FlxG.switchState(cast Type.createInstance(Main.game.initialState, []));

		FlxG.autoPause = false;

		var bianca:FlxSprite = new FlxSprite().loadGraphic(AssetHelper.grabAsset("splashScreen/biancaSplash", IMAGE, "images"));
		bianca.setGraphicSize(Std.int(bianca.width * 0.6));
		bianca.screenCenter(XY);
		bianca.x -= 1000;
		add(bianca);

		FlxTween.tween(bianca, {x: bianca.x + 980}, 0.9, {ease: FlxEase.quintInOut});
		FSound.playSound("splashRingSound");

		FlxTween.tween(bianca, {alpha: 0}, 2, {
			onComplete: function(t:FlxTween)
			{
				FlxG.save.data.seenSplash = true;
				FlxG.switchState(cast Type.createInstance(Main.game.initialState, []));
				OptionsAPI.updatePrefs();
			},
			ease: FlxEase.sineOut
		});
	}
}
