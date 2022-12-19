package funkin.objects;

import feather.tools.FeatherModule;
import feather.tools.FeatherSpriteManager.FeatherSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import funkin.essentials.song.Conductor;
import funkin.states.PlayState;
import haxe.Json;
import sys.FileSystem;

enum CharacterOrigin
{
	FUNKIN_FEATHER;
	FOREVER_FEATHER;
	FUNKIN_COCOA;
	PSYCH_ENGINE;
}

typedef PsychCharFile =
{
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

typedef PsychAnimsArray =
{
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
class Character extends FeatherSprite
{
	public var healthColor:Null<FlxColor>;
	public var charOffset:FlxPoint;
	public var camOffset:FlxPoint;

	public var character:String;
	public var icon:String;

	public var player:Bool = false;

	public var bopTimer:Float = 2;
	public var holdTimer:Float = 0;
	public var animTimer:Float = 0;
	public var dadVar:Float = 4; // this is the ONLY variable on this section that doesn't end with "Timer", oh lord

	public var hasMissAnims:Bool = false;
	public var isQuickDancer:Bool = false;
	public var danceIdle:Bool = false;

	public var idleSuffix:String = '';

	public var charType:CharacterOrigin = FUNKIN_FEATHER;

	public function new(player:Bool = false):Void
	{
		super(x, y);

		this.player = player;
	}

	public function setCharacter(x:Float, y:Float, char:String = 'bf'):Character
	{
		antialiasing = true;

		character = char;
		if (icon == null)
			icon = char;

		charOffset = new FlxPoint(0, 0);
		camOffset = new FlxPoint(0, 0);

		if (isQuickDancer)
			danceIdle = true;

		/**
			if (FileSystem.exists(AssetHelper.grabAsset(character, MODULE, "data/characters/" + character)))
				charType = FOREVER_FEATHER;

			if (FileSystem.exists(AssetHelper.grabAsset(character, JSON, "data/characters/" + character)))
				charType = PSYCH_ENGINE;
		**/

		switch (character)
		{
			case 'placeholder':
				frames = AssetHelper.grabAsset("placeholder", SPARROW, "data/characters/placeholder");

				animation.addByPrefix('idle', 'Idle', 24, false);
				animation.addByPrefix('singLEFT', 'Left', 24, false);
				animation.addByPrefix('singDOWN', 'Down', 24, false);
				animation.addByPrefix('singUP', 'Up', 24, false);
				animation.addByPrefix('singRIGHT', 'Right', 24, false);

				if (player)
				{
					addOffset("idle", 0, -350);
					addOffset("singLEFT", 50, -348);
					addOffset("singDOWN", 17, -375);
					addOffset("singUP", 8, -334);
					addOffset("singRIGHT", 22, -353);
					camOffset.set(30, 330);
					charOffset.set(0, -350);
				}
				else
				{
					addOffset("idle", 0, -10);
					addOffset("singLEFT", 33, -6);
					addOffset("singDOWN", -48, -31);
					addOffset("singUP", -45, 11);
					addOffset("singRIGHT", -61, -14);
					camOffset.set(0, -5);
				}

				healthColor = 0xFFA1A1A1;

			default:
				switch (charType)
				{
					case PSYCH_ENGINE:
						generatePsych(character);
					case FOREVER_FEATHER:
						generateFEFeather(character);
					default:
						return setCharacter(x, y, 'placeholder');
				}
		}

		var noteActions:Array<String> = funkin.objects.ui.notes.Strum.BabyArrow.actions;
		for (i in 0...noteActions.length)
		{
			if (animOffsets.exists('sing' + noteActions[i].toUpperCase() + 'miss'))
				hasMissAnims = true;
		}

		if (player)
		{
			flipX = !flipX;
			if (!character.startsWith('bf'))
				flipLeftRight();
		}
		else if (character.startsWith('bf'))
			flipLeftRight();

		dance();

		// x += charOffset.x;
		// y += (charOffset.y - (frameHeight * scale.y));

		this.x = x;
		this.y = y;

		return this;
	}

	function flipLeftRight():Void
	{
		// get the old right sprite
		var oldRight:Array<Int> = animation.getByName('singRIGHT').frames;
		var oldRightOff:Array<Dynamic> = animOffsets.get('singRIGHT');

		// set the right to the left
		animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;

		addOffset('singLEFT', oldRightOff[0], oldRightOff[1]);
		addOffset('singRIGHT', animOffsets.get('singLEFT')[0], animOffsets.get('singLEFT')[1]);

		// set the left to the old right
		animation.getByName('singLEFT').frames = oldRight;

		if (animation.getByName('singRIGHTmiss') != null)
		{
			var oldMiss:Array<Int> = animation.getByName('singRIGHTmiss').frames;
			var oldMissOff:Array<Dynamic> = animOffsets.get("singLEFTmiss");

			animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
			animation.getByName('singLEFTmiss').frames = oldMiss;

			addOffset('singLEFT', oldMissOff[0], oldMissOff[1]);
			addOffset('singRIGHT', animOffsets.get('singLEFTmiss')[0], animOffsets.get('singLEFTmiss')[1]);
		}
	}

	override function update(elapsed:Float):Void
	{
		if (animation.curAnim != null)
		{
			animTimer -= elapsed;
			if (animTimer <= 0)
				animation.finish();

			if (animation.curAnim.name.startsWith('sing'))
				holdTimer += elapsed;

			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}

			if (isQuickDancer)
			{
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
				if ((animation.curAnim.name.startsWith('sad')) && (animation.curAnim.finished))
					playAnim('danceLeft');
			}
		}

		super.update(elapsed);
	}

	private var isRight:Bool = false;

	public function dance():Void
	{
		if (animation.curAnim != null || animTimer <= 0)
		{
			if (isQuickDancer)
			{
				isRight = !isRight;

				var directionTo:String = (isRight ? "Right" : "Left");

				if (animOffsets.exists("dance" + directionTo + idleSuffix))
					playAnim("dance" + directionTo + idleSuffix);
			}
			else
				playAnim("idle" + idleSuffix);
		}
	}

	function generateFeather(char:String = 'bf'):Character
	{
		// yaml format.

		return this;
	}

	public var characterScripts:Array<FeatherModule> = [];

	function generateFEFeather(char:String = 'bf'):Character
	{
		var pushedChars:Array<String> = [];

		var charPath:String = 'data/characters/$char';
		var overrideFrames:String = null;
		var framesPath:String = null;

		if (!pushedChars.contains(char))
		{
			var script:FeatherModule = new FeatherModule(AssetHelper.grabAsset('config', MODULE, charPath), charPath);

			if (script.interp == null)
				trace("Something terrible occured! Skipping.");

			characterScripts.push(script);
			pushedChars.push(char);
		}

		var spriteType:AssetType = SPARROW;

		try
		{
			var textAsset = AssetHelper.grabAsset(char, TEXT, "data/characters/" + char);
			if (FileSystem.exists(textAsset))
				spriteType = PACKER;
			else
				spriteType = SPARROW;
		}
		catch (e)
		{
			trace('Could not define Sprite Type, Uncaught Error: ' + e);
			spriteType = SPARROW;
		}

		// frame overrides because why not;
		setVar('setFrames', function(newFrames:String, newFramesPath:String)
		{
			if (newFrames != null || newFrames != '')
				overrideFrames = newFrames;
			if (newFramesPath != null && newFramesPath != '')
				framesPath = newFramesPath;
		});

		var mainFrame:String = (overrideFrames == null ? char : overrideFrames);
		var framePath:String = (framesPath == null ? 'data/characters/$char' : framesPath);

		frames = AssetHelper.grabAsset(mainFrame, spriteType, framePath);

		setVar('addByPrefix', function(name:String, prefix:String, ?frames:Int = 24, ?loop:Bool = false)
		{
			animation.addByPrefix(name, prefix, frames, loop);
		});

		setVar('addByIndices', function(name:String, prefix:String, indices:Array<Int>, ?frames:Int = 24, ?loop:Bool = false)
		{
			animation.addByIndices(name, prefix, indices, "", frames, loop);
		});

		setVar('addOffset', function(?name:String = "idle", ?x:Float = 0, ?y:Float = 0)
		{
			addOffset(name, x, y);
		});

		setVar('set', function(name:String, value:Dynamic)
		{
			Reflect.setProperty(this, name, value);
		});

		setVar('setSingDuration', function(amount:Int)
		{
			dadVar = amount;
		});

		setVar('setOffsets', function(x:Float = 0, y:Float = 0)
		{
			charOffset.set(x, y);
		});

		setVar('setCamOffsets', function(x:Float = 0, y:Float = 0)
		{
			camOffset.set(x, y);
		});

		setVar('setScale', function(?x:Float = 1, ?y:Float = 1)
		{
			scale.set(x, y);
		});

		setVar('setIcon', function(swag:String = 'face') icon = swag);

		setVar('quickDancer', function(quick:Bool = false)
		{
			isQuickDancer = quick;
		});

		/**
			setVar('setBarColor', function(rgb:Array<Float>)
			{
				if (healthColor != null)
					healthColor = rgb;
				else
					healthColor = [161, 161, 161];
				return true;
			});
		**/

		setVar('setDeathChar',
			function(char:String = 'bf-dead', lossSfx:String = 'fnf_loss_sfx', song:String = 'gameOver', confirmSound:String = 'gameOverEnd', bpm:Int)
			{
				funkin.substates.GameOverSubstate.preferences = {
					character: char,
					sound: lossSfx,
					music: song,
					confirm: confirmSound,
					bpm: bpm
				};
			});

		setVar('get', function(variable:String)
		{
			return Reflect.getProperty(this, variable);
		});

		setVar('setGraphicSize', function(width:Int = 0, height:Int = 0)
		{
			setGraphicSize(width, height);
			updateHitbox();
		});

		setVar('playAnim', function(name:String, ?force:Bool = false, ?reversed:Bool = false, ?frames:Int = 0)
		{
			playAnim(name, force, reversed, frames);
		});

		setVar('isPlayer', player);
		setVar('player', player);
		if (PlayState.song != null)
			setVar('songName', PlayState.song.name.toLowerCase());
		setVar('flipLeftRight', flipLeftRight);

		if (characterScripts != null)
		{
			for (i in characterScripts)
				i.call('loadAnimations', []);
		}

		return this;
	}

	public function setVar(key:String, value:Dynamic):Bool
	{
		var allSucceed:Bool = true;
		if (characterScripts != null)
		{
			for (i in characterScripts)
			{
				i.set(key, value);

				if (!i.exists(key))
				{
					trace('${i.scriptFile} failed to set $key for its interpreter, continuing.');
					allSucceed = false;
					continue;
				}
			}
		}

		return allSucceed;
	}

	public var psychAnimationsArray:Array<PsychAnimsArray> = [];

	function generatePsych(char:String = 'bf'):Character
	{
		/**
			@author Shadow_Mario_
		**/
		var json:PsychCharFile = cast Json.parse(AssetHelper.grabAsset(char, JSON, "data/characters/" + char));

		var spriteType:AssetType = SPARROW;

		try
		{
			var textAsset = AssetHelper.grabAsset(json.image.replace('characters/', ''), TEXT, "data/characters/" + char);
			if (FileSystem.exists(textAsset))
				spriteType = PACKER;
			else
				spriteType = SPARROW;
		}
		catch (e)
		{
			trace('Could not define Sprite Type, Uncaught Error: ' + e);
			spriteType = SPARROW;
		}

		frames = AssetHelper.grabAsset(json.image.replace('characters/', ''), spriteType, "data/characters/" + char);

		trace(frames);

		psychAnimationsArray = json.animations;
		for (anim in psychAnimationsArray)
		{
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
		// healthIcon = json.healthicon;
		dadVar = json.sing_duration;

		if (json.scale != 1)
		{
			setGraphicSize(Std.int(width * json.scale));
			updateHitbox();
		}

		camOffset.set(json.camera_position[0], json.camera_position[1]);
		setPosition(json.position[0], json.position[1]);

		return this;
	}
}
