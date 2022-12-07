package funkin.objects;

import flixel.math.FlxPoint;
import funkin.backend.dependencies.FeatherTools.FeatherSprite;
import funkin.song.Conductor;
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
	public var charOffset:FlxPoint;
	public var camOffset:FlxPoint;

	public var character:String;

	public var player:Bool = false;

	public var bopTimer:Float = 2;
	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var dadVar:Float = 4;

	public var onSpecial:Bool = false;
	public var hasMissAnims:Bool = false;
	public var isQuickDancer:Bool = false;
	public var danceIdle:Bool = false;

	public var idleSuffix:String = '';

	public var defaultIdle:String = 'idle';

	public var charType:CharacterOrigin = FUNKIN_FEATHER;

	public var psychAnimationsArray:Array<PsychAnimsArray> = [];

	public function new(player:Bool = false):Void
	{
		super(x, y);

		this.player = player;
	}

	public function setCharacter(x:Float, y:Float, char:String = 'bf'):Character
	{
		antialiasing = true;

		character = char;

		charOffset = new FlxPoint(0, 0);
		camOffset = new FlxPoint(0, 0);

		if (isQuickDancer)
		{
			defaultIdle = 'danceRight';
			danceIdle = true;
		}

		if (FileSystem.exists(AssetHandler.grabAsset(character, JSON, "data/characters/" + character)))
			charType = PSYCH_ENGINE;

		switch (character)
		{
			default:
				switch (charType)
				{
					case PSYCH_ENGINE:
						/**
							@author Shadow_Mario_
						**/
						var json:PsychCharFile = cast Json.parse(AssetHandler.grabAsset('$character', JSON, 'data/characters/$character'));

						var spriteType:String = "SparrowAtlas";

						try
						{
							var textAsset = AssetHandler.grabAsset(json.image.replace('characters/', ''), TEXT, 'data/characters/$character');
							if (FileSystem.exists(textAsset))
								spriteType = "PackerAtlas";
							else
								spriteType = "SparrowAtlas";
						}
						catch (e)
						{
							trace('Could not define Sprite Type, Uncaught Error: ' + e);
						}

						switch (spriteType)
						{
							case "PackerAtlas":
								frames = AssetHandler.grabAsset(json.image.replace('characters/', ''), PACKER, 'data/characters/$character');
							default:
								frames = AssetHandler.grabAsset(json.image.replace('characters/', ''), SPARROW, 'data/characters/$character');
						}

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
						// healthColor = json.healthbar_colors;
						// healthIcon = json.healthicon;
						dadVar = json.sing_duration;

						if (json.scale != 1)
						{
							setGraphicSize(Std.int(width * json.scale));
							updateHitbox();
						}

						camOffset.set(json.camera_position[0], json.camera_position[1]);
						setPosition(json.position[0], json.position[1]);

					default:
						generatePlaceholder();
				}
		}

		for (i in 0...funkin.objects.ui.notes.BabyArrow.actions.length)
		{
			if (animOffsets.exists('sing' + funkin.objects.ui.notes.BabyArrow.actions[i].toUpperCase() + 'miss'))
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

		// "Preloads" animations so they dont lag in the song
		// author @DiogoTV
		var allAnims:Array<String> = animation.getNameList();
		for (anim in allAnims)
			playAnim(anim);

		dance();

		setPosition(x, y);
		this.x += charOffset.x;
		this.y += (charOffset.y - (frameHeight * scale.y));

		return this;
	}

	function flipLeftRight():Void
	{
		// get the old right sprite
		var oldRight = animation.getByName('singRIGHT').frames;

		// set the right to the left
		animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;

		// set the left to the old right
		animation.getByName('singLEFT').frames = oldRight;

		if (animation.getByName('singRIGHTmiss') != null)
		{
			var oldMiss = animation.getByName('singRIGHTmiss').frames;
			animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
			animation.getByName('singLEFTmiss').frames = oldMiss;
		}
	}

	function generatePlaceholder():Character
	{
		frames = AssetHandler.grabAsset("BOYFRIEND", SPARROW, "data/characters/bf");

		animation.addByPrefix('idle', 'BF idle dance', 24, false);
		animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
		animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
		animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
		animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
		animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
		animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
		animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
		animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
		animation.addByPrefix('hey', 'BF HEY', 24, false);

		addOffset('idle', -5);
		addOffset('hey', -3, 5);
		addOffset('singLEFT', 5, -6);
		addOffset('singDOWN', -20, -51);
		addOffset('singUP', -46, 27);
		addOffset('singRIGHT', -48, -7);
		addOffset('singLEFTmiss', 7, 19);
		addOffset('singDOWNmiss', -15, -19);
		addOffset('singUPmiss', -46, 27);
		addOffset('singRIGHTmiss', -44, 22);

		playAnim('idle');

		flipX = true;

		return this;
	}

	override function update(elapsed:Float):Void
	{
		if (animation.curAnim != null)
		{
			/**
				Special Animation Behavior Code
				@author Shadow_Mario_
			**/
			if (heyTimer > 0)
			{
				heyTimer -= elapsed;
				if (heyTimer <= 0)
				{
					if (onSpecial && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer')
					{
						onSpecial = false;
						dance();
					}
					heyTimer = 0;
				}
			}
			else if (onSpecial && animation.curAnim.finished)
			{
				onSpecial = false;
				dance();
			}

			if (!player && !onSpecial)
			{
				if (animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;

				if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
				{
					dance();
					holdTimer = 0;
				}
			}
			else if (!onSpecial)
			{
				if (animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;
				else
					holdTimer = 0;

				if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished)
					playAnim('idle', true, false, 10);

				if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished)
					playAnim('deathLoop');
			}
		}

		super.update(elapsed);
	}

	private var isRight:Bool = false;

	public function dance():Void
	{
		if (animation.curAnim != null || !onSpecial)
		{
			onSpecial = false;

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
}
