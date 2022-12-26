package;

import flixel.FlxG;
import flixel.FlxGame;
import funkin.backend.FPS;
import funkin.essentials.PlayerInfo;
import openfl.Lib;
import openfl.display.Sprite;

/**
	the `Main` class initializes our game along with a few useful tools for it,
	you may not find use for it unless you wanna change existing variales on it
**/
class Main extends Sprite {
	public static var game = {
		width: 1280, // the game window width
		height: 720, // the game window height
		zoom: -1.0, // defines the game's state bounds, -1.0 usually means automatic setup
		initialState: funkin.states.menus.MainMenu, // the game's initial state (shown after boot splash)
		framerate: 60, // the game's default framerate
		skipSplash: false, // whether the game boot splash should be skipped (defaults to false, changes true when seen once)
		fullscreen: false, // whether the game should start at fullscreen
		version: 'INFDEV', // the engine game version
	};

	public static var __justcompiled:Bool = false;

	public static function main():Void
		Lib.current.addChild(new Main());

	public function new():Void {
		super();

		// initialize the game controls for later use
		Controls.init();

		// initialize the discord rich presence wrapper
		DiscordRPC.init();

		// define the state bounds
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0) {
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
			__justcompiled = true;
		// compiling via terminal will set this to true, else it's false
		#end

		// initialize the highscore containers
		PlayerInfo.loadHighscores();

		// initialize the options api
		OptionsAPI.loadPrefs();

		addEvents();
	}

	private function addEvents():Void {
		FlxG.signals.preStateCreate.add(function(state:flixel.FlxState) {
			// clear unused (and stored, if allowed) memory
			AssetHelper.clear(true, (!Std.isOfType(state, funkin.states.PlayState)));
		});

		FlxG.stage.application.onUpdate.add(function(elapsed:Float):Void {
			FSound.update();
		});

		FlxG.signals.focusGained.add(function() {
			FSound.gainFocus();
		});

		FlxG.signals.focusLost.add(function() {
			FSound.loseFocus();
		});

		FlxG.stage.application.window.onClose.add(function() {
			Controls.destroy();
			DiscordRPC.destroy();
			FSound.destroy();
		});
	}
}
