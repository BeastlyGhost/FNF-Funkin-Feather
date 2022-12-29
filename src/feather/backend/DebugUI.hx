package feather.backend;

import flixel.FlxG;
import flixel.addons.display.shapes.FlxShapeBox;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.display.Sprite;

@:enum abstract UIType(String) to String {
	var CHECKBOX = 'checkbox';
	var DROPDOWN = 'dropdown';
	var BUTTON = 'button';
	var BOX = 'box';
}

class DebugUI {
	public var boxes:FlxTypedGroup<FlxShapeBox>;

	public function new(x:Float = 0, y:Float = 0, w:Float = 0, h:Float = 0, type:String = BOX):Void {
		boxes = new FlxTypedGroup<FlxShapeBox>();
	}

	public function drawBox():Void {}
}

class DebugConsole extends flixel.FlxObject {
	public var console:FlxShapeBox;

	public var curLine:Int = 0;

	/**
		array full of previously printed lines
		usually displays text as
		[LINE NUMBER] => [TEXT]
	**/
	public var allLines:Array<String> = [];

	public override function new():Void {
		super();

		console = new FlxShapeBox(20, 20, FlxG.width * 0.7, FlxG.height * 0.7, {thickness: 25}, 0xFF000000);

		haxe.Log.trace = function(v:Dynamic, ?infos:Null<haxe.PosInfos>) {
			var output = haxe.Log.formatOutput(v, infos);
			Sys.println(output);

			if (console != null) {
				curLine++;
				if (!allLines.contains('$curLine => $output'))
					allLines.push('$curLine => $output');
				while (allLines.length > 500) {
					allLines.shift();
				}
			}
		}
	}
}
