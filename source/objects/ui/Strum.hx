package objects.ui;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Strum extends FlxSpriteGroup
{
	public var babyArrows:FlxTypedSpriteGroup<BabyArrow>;
	public var characters:Array<Character>;

	public function new(x:Float, y:Float, characters:Array<Character>)
	{
		super();

		this.characters = characters;

		babyArrows = new FlxTypedSpriteGroup<BabyArrow>();

		for (i in 0...4)
		{
			var babyArrow:BabyArrow = new BabyArrow(i);

			babyArrow.setPosition(x, y);
			babyArrow.ID = i;

			babyArrow.frames = AssetHandler.grabAsset('NOTE_assets', SPARROW, 'images/ui/default');
			//
			babyArrow.animation.addByPrefix(babyArrow.colors[i], 'arrow' + babyArrow.actions[i].toUpperCase());
			babyArrow.animation.addByPrefix('static', 'arrow${babyArrow.actions[i].toUpperCase()}');
			babyArrow.animation.addByPrefix('pressed', '${babyArrow.actions[i]} press', 24, false);
			babyArrow.animation.addByPrefix('confirm', '${babyArrow.actions[i]} confirm', 24, false);

			babyArrow.x += (i - ((4 / 2))) * babyArrow.swagWidth;
			babyArrow.y -= 10;

			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			babyArrow.antialiasing = true;

			babyArrow.animation.play('static');
			babyArrows.add(babyArrow);

			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: babyArrow.defaultAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
		}

		add(babyArrows);
	}
}

class BabyArrow extends FeatherSprite
{
	public var index:Int = 0;

	public var swagWidth:Float = 160 * 0.7;

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
