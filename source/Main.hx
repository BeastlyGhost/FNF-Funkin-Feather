package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import funkin.backend.FPS;
import openfl.Lib;
import openfl.display.Sprite;

/**
	the `Main` class actually initializes our game,
	you may not find use for it unless you wanna change existing variales on it
**/
class Main extends Sprite
{
	public static var game = {
		width: 1280, // the game window width
		height: 720, // the game window height
		zoom: -1.0, // defines the game's state bounds, -1.0 usually means automatic setup
		initialState: funkin.states.menus.MainMenu, // the game's initial state (shown after boot splash)
		framerate: 120, // the game's default framerate
		skipSplash: false, // whether the game boot splash should be skipped (defaults to false, changes true when seen once)
		fullscreen: false, // whether the game should start at fullscreen
		version: '0.0.1-PA', // the engine game version
	};

	public static var __justcompiled:Bool = false;

	public static function main():Void
		Lib.current.addChild(new Main());

	public function new():Void
	{
		super();

		// initialize the game controls for later use
		Controls.init();

		// initialize the discord rich presence wrapper
		DiscordRPC.init();

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
		addChild(new FPS(0, 0));

		#if sys
		if (Sys.args().contains("-livereload"))
		{
			__justcompiled = true;
		}
		// if you typed in terminal "lime test windows" the __justcompiled will be true, and you will be able just to do stuff if you just built the game, if you open the game with the .exe file the __justcompiled will be false.
		#end

		FlxG.stage.application.window.onClose.add(function()
		{
			Controls.destroy();
			DiscordRPC.destroy();
		});
	}
}
