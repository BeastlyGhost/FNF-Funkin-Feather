package fnf.states;

import feather.tools.FeatherModule;
import feather.tools.FeatherToolkit.PlumaUIState;
import flixel.FlxSubState;
import flixel.math.FlxMath;

/**
	Parent State that handles the entire state structure from the project
	it can also be extended by a script itself
**/
class ScriptableState extends PlumaUIState {
	public var selection:Float = 0; // Defines the Current Selected Item on a State

	public var wrappableGroup:Array<Dynamic> = []; // Defines the `selection` limits

	public var stateModule:FeatherModule;

	public override function create():Void {
		super.create();
	}

	public function updateSelection(newSelection:Int = 0):Void {
		if (wrappableGroup.length > 0)
			selection = FlxMath.wrap(Math.floor(selection) + newSelection, 0, wrappableGroup.length - 1);
	}
}

class ScriptableSubstate extends FlxSubState {
	public var selection:Float = 0;

	public var wrappableGroup:Array<Dynamic> = [];

	public var substateModule:FeatherModule;

	public override function create():Void {
		super.create();
	}

	public function updateSelection(newSelection:Int = 0):Void {
		if (wrappableGroup.length > 0)
			selection = FlxMath.wrap(Math.floor(selection) + newSelection, 0, wrappableGroup.length - 1);
	}
}
