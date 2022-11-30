package funkin.objects;

import base.utils.FeatherUtils.FeatherSprite;
import flixel.math.FlxPoint;
import funkin.song.Conductor;

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

	public var singAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var defaultIdle:String = 'idle';

	public function new(player:Bool = false):Void
	{
		super(x, y);

		this.player = player;
	}

	public function setCharacter(x:Float, y:Float, char:String = 'bf')
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

		switch (character)
		{
			default:
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
		}

		for (anim in singAnims)
		{
			if (animOffsets.exists(anim + 'miss'))
				hasMissAnims = true;
		}

		if (player) // fuck you ninjamuffin lmao
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

		recalcDance();
		dance();

		this.x += charOffset.x;
		this.y += (charOffset.y - (frameHeight * scale.y));

		setPosition(x, y);

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

	override function update(elapsed:Float)
	{
		if (animation.curAnim != null)
		{
			/**
			 * Special Animation Behavior Code
			 * @author Shadow_Mario_
			 */
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
		}

		super.update(elapsed);
	}

	private var isRight:Bool = false;

	public function dance()
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

	private var settingCharacterUp:Bool = true;

	/**
	 * Recalculates Character Headbop Speed, used by GF-Like Characters;
	 * @author Shadow_Mario_
	**/
	public function recalcDance()
	{
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (animation.getByName('danceLeft' + idleSuffix) != null && animation.getByName('danceRight' + idleSuffix) != null);

		if (settingCharacterUp)
			bopTimer = (danceIdle ? 1 : 2);
		else if (lastDanceIdle != danceIdle)
		{
			var calc:Float = bopTimer;
			if (danceIdle)
				calc /= 2;
			else
				calc *= 2;

			bopTimer = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
	}
}

/*
	Placeholder
**/
class Player extends Character
{
	public var stunned:Bool = false;

	public function new()
		super(true);

	override function update(elapsed:Float)
	{
		if (animation.curAnim.name.startsWith('sing'))
			holdTimer += elapsed;
		else
			holdTimer = 0;

		if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished)
			playAnim('idle', true, false, 10);

		if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished)
			playAnim('deathLoop');

		super.update(elapsed);
	}
}
