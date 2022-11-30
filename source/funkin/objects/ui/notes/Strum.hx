package funkin.objects.ui.notes;

import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.states.PlayState;

/**
	Strum class, initializes the gray notes at the top / bottom of the screen,
	it also comes with a set of functions for handling said notes
**/
class Strum extends FlxSpriteGroup
{
	public var babyArrows:FlxTypedSpriteGroup<BabyArrow>;

	public var characters:Array<Character>;
	public var autoplay:Bool = true;

	public function new(x:Float, y:Float, characters:Array<Character>, autoplay:Bool = true)
	{
		super();

		this.characters = characters;
		this.autoplay = autoplay;

		babyArrows = new FlxTypedSpriteGroup<BabyArrow>();

		for (index in 0...4)
		{
			var babyArrow:BabyArrow = new BabyArrow(index);

			babyArrow.setPosition(x, y);
			babyArrow.ID = index;

			switch (PlayState.assetSkin)
			{
				case "pixel":
					babyArrow.loadGraphic(AssetHandler.grabAsset('NOTE_assets', IMAGE, 'images/ui/pixel'), true, 17, 17);
					//
					babyArrow.animation.add('static', [index]);
					babyArrow.animation.add('pressed', [4 + index, 8 + index], 12, false);
					babyArrow.animation.add('confirm', [12 + index, 16 + index], 12, false);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * PlayState.pixelAssetSize));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					babyArrow.addOffset('static', -67, -50);
					babyArrow.addOffset('pressed', -67, -50);
					babyArrow.addOffset('confirm', -67, -50);

					babyArrow.x += 5;
					babyArrow.y += 25;

				default:
					babyArrow.frames = AssetHandler.grabAsset('NOTE_assets', SPARROW, 'images/ui/default');
					//
					babyArrow.animation.addByPrefix(babyArrow.colors[index], 'arrow' + babyArrow.actions[index].toUpperCase());
					babyArrow.animation.addByPrefix('static', 'arrow${babyArrow.actions[index].toUpperCase()}');
					babyArrow.animation.addByPrefix('pressed', '${babyArrow.actions[index]} press', 24, false);
					babyArrow.animation.addByPrefix('confirm', '${babyArrow.actions[index]} confirm', 24, false);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
					babyArrow.antialiasing = true;
			}

			babyArrow.x += (index - ((4 / 2))) * BabyArrow.swagWidth;
			babyArrow.y -= 10;

			babyArrow.animation.play('static');
			babyArrows.add(babyArrow);

			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: babyArrow.defaultAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * index)});
		}

		add(babyArrows);
	}
}

/**
	`BabyArrow`s are sprites that are attached to your `Strum`line,
	this class simply initializes said `BabyArrow`s
**/
class BabyArrow extends FeatherSprite
{
	public var index:Int = 0;

	public static var swagWidth:Float = 160 * 0.7;

	public var actions:Array<String> = ['left', 'down', 'up', 'right'];
	public var colors:Array<String> = ['purple', 'blue', 'green', 'red'];

	public var defaultAlpha:Float = 0.8;

	public function new(index:Int)
	{
		super(x, y);

		alpha = defaultAlpha;

		this.index = index;

		updateHitbox();
		scrollFactor.set();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		super.playAnim(AnimName);

		centerOffsets();
		centerOrigin();
	}

	public function getColor(index:Int)
		return colors[index];

	public function getAction(index:Int)
		return actions[index];
}
