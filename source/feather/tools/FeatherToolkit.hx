package feather.tools;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.util.FlxSave;
import funkin.backend.Transition;
import sys.FileSystem;

typedef SaveFile = {
	var fileName:String;
	var fileData:Dynamic;
}

/**
	Flixel Sprite Extension made for characters! 
**/
class PlumaSprite extends FlxSprite {
	//
	public var animOffsets:Map<String, Array<Dynamic>>;

	public function new(x:Float = 0, y:Float = 0):Void {
		super(x, y);
		animOffsets = new Map<String, Array<Dynamic>>();
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void {
		animation.play(AnimName, Force, Reversed, Frame);

		centerOffsets();
		centerOrigin();

		var daOffset:Array<Dynamic> = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
			offset.set(daOffset[0], daOffset[1]);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0):Void
		animOffsets[name] = [x, y];

	public override function destroy():Void {
		if (graphic != null)
			graphic.dump();
		super.destroy();
	}
}

/**
	a Sprite that follows a parent sprite
**/
class ChildSprite extends PlumaSprite {
	public var parentSprite:FlxSprite;

	public var addX:Float = 0;
	public var addY:Float = 0;
	public var addAngle:Float = 0;
	public var addAlpha:Float = 0;

	public var copyParentAngle:Bool = false;
	public var copyParentAlpha:Bool = false;
	public var copyParentVisib:Bool = false;

	public function new(fileName:String, ?fileFolder:String, ?fileAnim:String, ?looped:Bool = false):Void {
		super(x, y);

		if (fileName != null) {
			if (fileAnim != null) {
				frames = AssetHelper.grabAsset(fileName, SPARROW, fileFolder);
				animation.addByPrefix('static', fileAnim, 24, looped);
				animation.play('static');
			} else
				loadGraphic(AssetHelper.grabAsset(fileName, IMAGE, fileFolder));
			scrollFactor.set();
		}
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		// set parent sprite stuffs;
		if (parentSprite != null) {
			setPosition(parentSprite.x + addX, parentSprite.y + addY);
			scrollFactor.set(parentSprite.scrollFactor.x, parentSprite.scrollFactor.y);

			if (copyParentAngle)
				angle = parentSprite.angle + addAngle;

			if (copyParentAlpha)
				alpha = parentSprite.alpha * addAlpha;

			if (copyParentVisib)
				visible = parentSprite.visible;
		}
	}
}

/**
	Global Transition for EVERY State
	@since INFDEV
**/
class PlumaUIState extends FlxUIState {
	public var defaultTransition:TransType = Slide_UpDown;

	public override function create():Void {
		// play the transition if we are allowed to
		if (!FlxTransitionableState.skipNextTransOut)
			Transition.start(0.3, false, defaultTransition, FlxEase.linear);
	}
}

/**
	String Tools for any type of String Expression
**/
class PlumaStrings {
	/**
		Format Strings as a Title. Example: ``'world_machine' -> 'World Machine'``.
	**/
	inline public static function toTitle(str:String):String {
		var splits:Array<String> = str.toLowerCase().split(" ");

		for (i in 0...splits.length)
			splits[i] = splits[i].charAt(0).toUpperCase() + splits[i].substr(1);

		return splits.join(" ");
	}
}

class PlumaSave {
	public static var pathBase:String = './assets/data/save';

	public static var saveBinder:Map<String, SaveFile>;

	// generated automatically by random code
	public static var saveHash:Map<String, String>;

	public static function bind(name:String):Void {
		if (saveBinder == null)
			saveBinder = new Map<String, SaveFile>();

		if (saveHash == null)
			saveHash = new Map<String, String>();

		saveBinder.set(name, {fileName: name, fileData: null});
		// trace("Data on Save is: " + saveBinder);
	}

	public static function save(name:String, data:Dynamic, ?store:Bool = true):Void {
		if (saveBinder == null)
			return;

		if (saveBinder.exists(name))
			saveBinder.set(name, {fileName: name, fileData: data});

		/**
				if (!FileSystem.exists('$pathBase/save'))
					FileSystem.createDirectory('$pathBase/save');

				if (!FileSystem.exists(AssetHelper.grabAsset(name, JSON, 'data/save')))
			{
					var path:String = '$pathBase/$name.json';
					File.saveContent(path, '${saveBinder.get(name)}');
				}
		**/

		trace("Data on Save is: " + saveBinder);
	}

	public static function load(name:String):Void {
		if (!FileSystem.exists(AssetHelper.grabAsset(name, JSON, 'data/save')))
			return;
	}

	public static function getSavePath():String {
		@:privateAccess
		return #if (flixel < "5.0.0") 'BeastlyGhost' #else FlxG.stage.application.meta.get('company')
			+ '/'
			+ FlxSave.validate(FlxG.stage.application.meta.get('file')) #end;
	}
}

/**
	the Sound Manager class contains various tools for sound controls and such
	WIP
**/
class PlumaSound {
	private static var createdSound:FlxSound;

	public static function playSound(name:String, folder:String = "sounds", persist:Bool = false, volume:Float = 1):Void {
		createdSound = new FlxSound().loadEmbedded(AssetHelper.grabAsset(name, SOUND, folder));
		createdSound.volume = volume;
		createdSound.persist = persist;
		createdSound.play();
	}

	public static function loseFocus():Void {
		if (!FlxG.autoPause)
			return;

		if (createdSound != null)
			if (createdSound.playing)
				createdSound.pause();
	}

	public static function gainFocus():Void {
		if (createdSound != null)
			if (!createdSound.playing)
				createdSound.resume();
	}

	public static function update():Void {
		if (createdSound != null)
			if (createdSound.time == createdSound.length)
				createdSound.stop();
	}

	/**
		Persona 3 Mass Destruction
	**/
	public static function destroy():Void {
		if (createdSound != null)
			createdSound.stop();
	}
}
