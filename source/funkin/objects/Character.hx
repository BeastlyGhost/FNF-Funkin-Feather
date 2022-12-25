package funkin.objects;

import feather.tools.FeatherModule;
import feather.tools.FeatherToolkit.PlumaSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import funkin.essentials.song.Conductor;
import funkin.states.PlayState;
import haxe.Json;
import sys.FileSystem;

typedef PsychCharFile = {
	var animations:Array<PsychAnimsArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;
	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
}

typedef PsychAnimsArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

/**
	Character class, initializes all characters that are present during gameplay
	and handles their animations
**/
class Character extends PlumaSprite {
	public var charOffset:FlxPoint;
	public var camOffset:FlxPoint;

	public var name:String;

	public var healthIcon:String;
	public var healthColor:Null<FlxColor>;

	public var player:Bool = false;

	public var timers:{
		headBop:Null<Float>,
		hold:Null<Float>,
		animation:Null<Float>,
		sing:Null<Float>
	} = {
		headBop: 2,
		hold: 0,
		animation: 0,
		sing: 4
	};

	public var isDebug:Bool = false;
	public var hasMissAnims:Bool = false;
	public var isQuickDancer:Bool = false;

	public var idleSuffix:String = '';

	// for character scripts later on
	public var characterScripts:Array<FeatherModule> = [];
	public var psychAnimationsArray:Array<PsychAnimsArray> = [];

	public function new(player:Bool = false):Void {
		super(x, y);

		this.player = player;
	}

	public function setCharacter(x:Float = 0, y:Float = 0, char:String = 'bf', ?implementation:Implementation = FEATHER):Character {
		antialiasing = true;

		if (implementation == null)
			implementation = FEATHER;

		name = char;
		if (healthIcon == null)
			healthIcon = name;

		charOffset = new FlxPoint(0, 0);
		camOffset = new FlxPoint(0, 0);

		if (FileSystem.exists(AssetHelper.grabAsset(name, JSON, 'data/characters/$name')))
			implementation = PSYCH;

		switch (char) {
			default:
				if (implementation == PSYCH)
					generatePsych(name);
				else
					generateFeather(name);
		}

		this.x = x;
		this.y = y;

		postGenChecks();

		return this;
	}

	function postGenChecks():Void {
		if (graphic == null)
			return;

		var noteActions:Array<String> = funkin.objects.ui.Note.BabyArrow.actions;
		for (i in 0...noteActions.length) {
			if (animOffsets.exists('sing' + noteActions[i].toUpperCase() + 'miss'))
				hasMissAnims = true;
		}

		if (player) {
			flipX = !flipX;
			if (!name.startsWith('bf'))
				flipLeftRight();
		} else if (name.startsWith('bf'))
			flipLeftRight();

		// Plays all animations prior to starting
		var allAnims:Array<String> = animation.getNameList();
		for (anim in allAnims) {
			playAnim(anim);
			dance();
		}

		dance();

		// x += charOffset.x;
		// y += (charOffset.y - (frameHeight * scale.y));
	}

	function flipLeftRight():Void {
		// get the old right sprite
		var oldRight:Array<Int> = animation.getByName('singRIGHT').frames;

		// set the right to the left
		animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;

		// set the left to the old right
		animation.getByName('singLEFT').frames = oldRight;

		if (animation.getByName('singRIGHTmiss') != null) {
			var oldMiss:Array<Int> = animation.getByName('singRIGHTmiss').frames;
			animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
			animation.getByName('singLEFTmiss').frames = oldMiss;
		}
	}

	override function update(elapsed:Float):Void {
		if (animation.curAnim != null && !isDebug) {
			if (timers.animation > 0) {
				timers.animation -= elapsed;

				if (timers.animation <= 0) {
					dance();
					timers.animation = 0;
				}
			}

			if (animation.curAnim.name.startsWith('sing'))
				timers.hold += elapsed;

			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished)
				playAnim('idle', true, false, 10);

			if (timers.hold >= Conductor.stepCrochet * (0.001 * Conductor.songRate) * timers.sing) {
				dance();
				timers.hold = 0;
			}

			if (isQuickDancer) {
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
				if ((animation.curAnim.name.startsWith('sad')) && (animation.curAnim.finished))
					playAnim('danceLeft');
			}

			for (i in characterScripts) {
				if (i != null)
					i.call('loadAanimtions', []);
			}
		}

		super.update(elapsed);
	}

	private var isRight:Bool = false;

	public function dance():Void {
		if (animation.curAnim != null && !isDebug) {
			if (isQuickDancer) {
				isRight = !isRight;

				var directionTo:String = (isRight ? "Right" : "Left");
				if (animOffsets.exists("dance" + directionTo + idleSuffix))
					playAnim("dance" + directionTo + idleSuffix);
			} else
				playAnim("idle" + idleSuffix);
		}
	}

	/**
		GENERATION SCRIPTS
	**/
	function generatePlaceholder():Void {
		frames = AssetHelper.grabAsset("placeholder", SPARROW, "data/characters/placeholder");

		animation.addByPrefix('idle', 'Idle', 24, false);
		animation.addByPrefix('singLEFT', 'Left', 24, false);
		animation.addByPrefix('singDOWN', 'Down', 24, false);
		animation.addByPrefix('singUP', 'Up', 24, false);
		animation.addByPrefix('singRIGHT', 'Right', 24, false);

		if (player) {
			addOffset("idle", 0, -350);
			addOffset("singLEFT", 50, -348);
			addOffset("singDOWN", 17, -375);
			addOffset("singUP", 8, -334);
			addOffset("singRIGHT", 22, -353);
			camOffset.set(30, 330);
			charOffset.set(0, -350);
		} else {
			addOffset("idle", 0, -10);
			addOffset("singLEFT", 33, -6);
			addOffset("singDOWN", -48, -31);
			addOffset("singUP", -45, 11);
			addOffset("singRIGHT", -61, -14);
			camOffset.set(0, -5);
		}

		healthColor = 0xFFA1A1A1;
	}

	function generateFeather(char:String):Character {
		var pathRaw:String = 'data/characters/$char';
		var path:String = AssetHelper.grabAsset('config', MODULE, 'data/characters/$char');
		if (FileSystem.exists(path)) {
			try {
				var script:FeatherModule = new FeatherModule(path, pathRaw);
				if (!characterScripts.contains(script))
					characterScripts.push(script);

				var spriteType:AssetType = SPARROW;

				try {
					var textAsset = AssetHelper.grabAsset(char, TEXT, pathRaw);
					if (FileSystem.exists(textAsset))
						spriteType = PACKER;
					else
						spriteType = SPARROW;
				}
				catch (e:Dynamic) {
					trace('Could not define Sprite Type, Error: ' + e);
					spriteType = SPARROW;
				}

				frames = AssetHelper.grabAsset(char, spriteType, pathRaw);

				for (i in characterScripts) {
					if (i != null) {
						i.set('character', this);
						i.set('songName', PlayState.song.name.toLowerCase());
						i.call('loadAnimations', []);
					}
				}
			}
			catch (e:Dynamic)
				generatePlaceholder();
		}

		return this;
	}

	function generatePsych(char:String = 'bf'):Character {
		/**
			@author Shadow_Mario_
		**/
		var json:PsychCharFile = cast Json.parse(AssetHelper.grabAsset(char, JSON, 'data/characters/$char'));

		var spriteType:AssetType = SPARROW;

		try {
			var textAsset = AssetHelper.grabAsset(json.image, TEXT, 'data/characters/$char');
			if (FileSystem.exists(textAsset))
				spriteType = PACKER;
			else
				spriteType = SPARROW;
		}
		catch (e:Dynamic) {
			trace('Could not define Sprite Type, Uncaught Error: ' + e);
			spriteType = SPARROW;
		}

		frames = AssetHelper.grabAsset(json.image, spriteType, 'data/characters/$char');

		psychAnimationsArray = json.animations;
		for (anim in psychAnimationsArray) {
			var animAnim:String = '' + anim.anim;
			var animName:String = '' + anim.name;
			var animFps:Int = anim.fps;
			var animLoop:Bool = !!anim.loop; // Bruh
			var animIndices:Array<Int> = anim.indices;
			if (animIndices != null && animIndices.length > 0)
				animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
			else
				animation.addByPrefix(animAnim, animName, animFps, animLoop);

			if (anim.offsets != null && anim.offsets.length > 1)
				addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
		}

		flipX = json.flip_x;
		antialiasing = !json.no_antialiasing;
		healthColor = FlxColor.fromRGB(json.healthbar_colors[0], json.healthbar_colors[1], json.healthbar_colors[2]);
		healthIcon = json.healthicon;
		timers.sing = json.sing_duration;

		if (json.scale != 1) {
			setGraphicSize(Std.int(width * json.scale));
			updateHitbox();
		}

		camOffset.set(json.camera_position[0], json.camera_position[1]);
		setPosition(json.position[0], json.position[1]);

		return this;
	}

	/**
		Misc Functions for Characters
	**/
	public function setBarColor(rgb:Array<Int>):Void
		healthColor = FlxColor.fromRGB(Std.int(rgb[0]), Std.int(rgb[1]), Std.int(rgb[2]));

	public function setCharSize(width:Int, height:Int):Void {
		setGraphicSize(width, height);
		updateHitbox();
	}

	public function setDeathChar(char:String = 'bf-dead', lossSfx:String = 'fnf_loss_sfx', song:String = 'gameOver', confirmSound:String = 'gameOverEnd',
			bpm:Int = 100):Void {
		funkin.substates.GameOverSubstate.preferences = {
			character: char,
			sound: lossSfx,
			music: song,
			confirm: confirmSound,
			bpm: bpm
		};
	}
}
