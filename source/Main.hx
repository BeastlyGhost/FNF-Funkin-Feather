package;

import base.DebugInfo;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.Lib;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var game = {
		width: 1280, // the game window width
		height: 720, // the game window height
		zoom: -1.0, // defines the game's state bounds, -1.0 usually means automatic setup
		initialState: states.PlayState, // the game's initial state (shown after boot splash)
		framerate: 120, // the game's default framerate
		skipSplash: false, // whether the game boot splash should be skipped (defaults to false, changes true when seen once)
		fullscreen: false, // whether the game should start at fullscreen
		version: 'PRIVATE PRE-ALPHA', // the engine game version
	};

	public static function main():Void
		Lib.current.addChild(new Main());

	public function new()
	{
		super();

		// initialize the game controls for later use
		base.Controls.init();

		// define the state bounds
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0)
		{
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}

		addChild(new FlxGame(game.width, game.height, Start, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, true, game.fullscreen));
		addChild(new DebugInfo(0, 0));

		FlxG.stage.application.window.onClose.add(function()
		{
			destroyGame();
		});
	}

	function destroyGame()
	{
		base.Controls.destroy();
		Sys.exit(1);
	}
}
