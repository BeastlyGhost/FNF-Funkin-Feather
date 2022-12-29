package;

import feather.backend.DebugUI;
import flixel.FlxG;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

/**
	Starting Class for the game
	used to set up useful functions and variables for the main game!
**/
class Start extends FlxState {
	public var consoleUI:DebugConsole;

	public override function create():Void {
		super.create();

		if (FlxG.save.data != null)
			OptionsAPI.updatePrefs();

		FlxG.fixedTimestep = true;
		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = false;

		triggerSplash(Main.game.skipSplash);
	}

	function triggerSplash(skip:Bool):Void {
		if (skip)
			return FlxG.switchState(cast Type.createInstance(Main.game.initialState, []));

		FlxG.autoPause = false;

		var bianca:PlumaSprite = new PlumaSprite();
		bianca.loadGraphic(AssetHelper.grabAsset("splashScreen/biancaSplash", IMAGE, "images"));
		bianca.setGraphicSize(Std.int(bianca.width * 0.6));
		bianca.screenCenter(XY);
		bianca.x -= 1000;
		add(bianca);

		FlxTween.tween(bianca, {x: bianca.x + 980}, 0.9, {ease: FlxEase.quintInOut});
		FSound.playSound("splashRingSound");

		FlxTween.tween(bianca, {alpha: 0}, 2, {
			onComplete: function(t:FlxTween) {
				addCompilerObjects();
				FlxG.switchState(cast Type.createInstance(Main.game.initialState, []));
			},
			ease: FlxEase.sineOut
		});
	}

	public function addCompilerObjects():Void {
		//#if INC_FEATHERDEBUG
		consoleUI = new DebugConsole();
		add(consoleUI);
		//#end
	}
}
