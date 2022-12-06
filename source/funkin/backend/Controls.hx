package funkin.backend;

import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import flixel.FlxG;
import flixel.util.FlxSignal.FlxTypedSignal;

// TODO: implement gamepad input
typedef Action =
{
	var keyboard:Array<Int>;
};

typedef KeyCall = (Int, String) -> Void; // for convenience

/**
	the Controls Class manages the main inputs for the game,
	it can be used by every other class for any type of event
**/
class Controls
{
	public static final defaultActions:Map<String, Action> = [
		"left" => {keyboard: [Keyboard.LEFT, Keyboard.D]},
		"down" => {keyboard: [Keyboard.DOWN, Keyboard.F]},
		"up" => {keyboard: [Keyboard.UP, Keyboard.J]},
		"right" => {keyboard: [Keyboard.RIGHT, Keyboard.K]},
		"accept" => {keyboard: [Keyboard.ENTER, Keyboard.SPACE]},
		"pause" => {keyboard: [Keyboard.ENTER, Keyboard.P]},
		"back" => {keyboard: [Keyboard.ESCAPE, Keyboard.BACKSPACE]},
	];
	public static var actions(default, null):Map<String, Action>;

	public static var onKeyPressed(default, null):FlxTypedSignal<KeyCall> = new FlxTypedSignal<KeyCall>();
	public static var onKeyReleased(default, null):FlxTypedSignal<KeyCall> = new FlxTypedSignal<KeyCall>();

	static var keysHeld:Array<Int> = []; // for keyboard keys

	public static function init()
	{
		actions = defaultActions.copy();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}

	public static function destroy()
	{
		actions = null;

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}

	public static function getActionFromKey(key:Int)
	{
		for (id => action in actions)
		{
			if (action.keyboard.contains(key))
				return id;
		}
		return null;
	}

	public static function isPressed(action:String)
	{
		for (key in actions.get(action).keyboard)
		{
			if (keysHeld.contains(key))
				return true;
		}
		return false;
	}

	public static function isJustPressed(action:String)
	{
		for (key in actions.get(action).keyboard)
		{
			if (keysHeld.contains(key) && FlxG.keys.checkStatus(key, JUST_PRESSED))
				return true;
		}
		return false;
	}

	static function onKeyDown(evt:KeyboardEvent)
	{
		if (FlxG.keys.enabled && (FlxG.state.active || FlxG.state.persistentUpdate) && !keysHeld.contains(evt.keyCode))
		{
			keysHeld.push(evt.keyCode);
			onKeyPressed.dispatch(evt.keyCode, getActionFromKey(evt.keyCode));
		}
	}

	static function onKeyUp(evt:KeyboardEvent)
	{
		if (FlxG.keys.enabled && (FlxG.state.active || FlxG.state.persistentUpdate) && keysHeld.contains(evt.keyCode))
		{
			keysHeld.remove(evt.keyCode);
			onKeyReleased.dispatch(evt.keyCode, getActionFromKey(evt.keyCode));
		}
	}
}
