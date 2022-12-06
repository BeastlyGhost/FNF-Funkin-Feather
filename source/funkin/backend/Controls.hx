package funkin.backend;

import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import flixel.FlxG;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;

typedef Action =
{
	var keyboard:Array<Int>;
	var gamepad:Array<FlxGamepadInputID>;
};

typedef KeyCall = (Int, String, Bool) -> Void; // for convenience

/**
	the Controls Class manages the main inputs for the game,
	it can be used by every other class for any type of event
**/
class Controls
{
	public static final defaultActions:Map<String, Action> = [
		"left" => {keyboard: [Keyboard.LEFT, Keyboard.D], gamepad: [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT]},
		"down" => {keyboard: [Keyboard.DOWN, Keyboard.F], gamepad: [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN]},
		"up" => {keyboard: [Keyboard.UP, Keyboard.J], gamepad: [DPAD_UP, LEFT_STICK_DIGITAL_UP]},
		"right" => {keyboard: [Keyboard.RIGHT, Keyboard.K], gamepad: [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT]},
		"accept" => {keyboard: [Keyboard.ENTER, Keyboard.SPACE], gamepad: [A, START]},
		"pause" => {keyboard: [Keyboard.ENTER, Keyboard.P], gamepad: [START]},
		"back" => {keyboard: [Keyboard.ESCAPE, Keyboard.BACKSPACE], gamepad: [B]},
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

		FlxG.signals.preUpdate.add(update);
	}

	public static function destroy()
	{
		actions = null;

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);

		FlxG.signals.preUpdate.remove(update);
	}

	public static function getActionFromKey(key:Int, isGamepad:Bool = false)
	{
		for (id => action in actions)
		{
			if ((!isGamepad && action.keyboard.contains(key)) || (isGamepad && action.gamepad.contains(key)))
				return id;
		}
		return null;
	}

	public static function isJustPressed(action:String)
	{
		var action:Action = actions.get(action);

		for (key in action.keyboard)
		{
			if (keysHeld.contains(key) && FlxG.keys.checkStatus(key, JUST_PRESSED))
				return true;
		}

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
		{
			for (key in action.gamepad)
			{
				if (gamepad.checkStatus(key, JUST_PRESSED))
					return true;
			}
		}

		return false;
	}

	public static function isPressed(action:String)
	{
		var action:Action = actions.get(action);

		for (key in action.keyboard)
		{
			if (keysHeld.contains(key))
				return true;
		}

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
		{
			for (key in action.gamepad)
			{
				if (gamepad.checkStatus(key, PRESSED))
					return true;
			}
		}

		return false;
	}

	static function onKeyDown(evt:KeyboardEvent)
	{
		if (FlxG.keys.enabled && (FlxG.state.active || FlxG.state.persistentUpdate) && !keysHeld.contains(evt.keyCode))
		{
			keysHeld.push(evt.keyCode);
			onKeyPressed.dispatch(evt.keyCode, getActionFromKey(evt.keyCode), false);
		}
	}

	static function onKeyUp(evt:KeyboardEvent)
	{
		if (FlxG.keys.enabled && (FlxG.state.active || FlxG.state.persistentUpdate) && keysHeld.contains(evt.keyCode))
		{
			keysHeld.remove(evt.keyCode);
			onKeyReleased.dispatch(evt.keyCode, getActionFromKey(evt.keyCode), false);
		}
	}

	static function update()
	{
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
		{
			for (id => action in actions)
			{
				for (key in action.gamepad)
				{
					if (gamepad.checkStatus(key, JUST_PRESSED))
						onKeyPressed.dispatch(key, id, true);
					if (gamepad.checkStatus(key, JUST_RELEASED))
						onKeyReleased.dispatch(key, id, true);
				}
			}
		}
	}
}
