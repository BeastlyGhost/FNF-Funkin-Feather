package objects;

import base.utils.FeatherUtils.FeatherSprite;
import flixel.math.FlxPoint;

class Character extends FeatherSprite
{
	public var charOffset:FlxPoint;
	public var camOffset:FlxPoint;

	public var character:String;

	public var player:Bool = false;
	public var holdTimer:Float = 0;
	public var dadVar:Float = 4;

	public var isQuickDancer:Bool = false;

	public var idleSuffix:String = '';

	public var defaultSingAnims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var defaultIdle:String = 'idle';

	public function new(player:Bool):Void
	{
		super(x, y);

		this.player = player;
	}

	public function setCharacter(x:Float, y:Float, char:String = 'bf')
	{
		antialiasing = true;

		charOffset = new FlxPoint(0, 0);
		camOffset = new FlxPoint(0, 0);

		if (isQuickDancer)
			defaultIdle = 'danceRight';

		switch (character)
		{
			default:
				frames = AssetHandler.grabAsset("BOYFRIEND", SPARROW, "data/characters/bf");

				animation.addByPrefix('idle', 'BF idle dance', 24, false);

				addOffset('idle', -5);
				playAnim('idle');

				if (!player)
					y += 320;

				flipX = true;
		}

		dance();

		if (player)
			flipX = !flipX;

		/*
			x += charOffset.x;
			y += (charOffset.y - (frameHeight * scale.y));

			this.x = x;
			this.y = y;
		 */

		setPosition(x, y);

		return this;
	}

	private var isRight:Bool = false;

	public function dance()
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
