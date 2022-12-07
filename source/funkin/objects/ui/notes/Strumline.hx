package funkin.objects.ui.notes;

import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.states.PlayState;

/**
	Strumline class, initializes the gray notes at the top / bottom of the screen,
	it also comes with a set of functions for handling said notes
**/
class Strumline extends FlxGroup
{
	public var characters:Array<Character>;

	public var babyArrows:FlxTypedGroup<BabyArrow>;
	public var splashes:FlxTypedGroup<NoteSplash>;

	public var downscroll:Bool = false;
	public var autoplay:Bool = true;

	public function new(x:Float, y:Float, characters:Array<Character>, autoplay:Bool = true, downscroll:Bool = false):Void
	{
		super();

		this.characters = characters;
		this.autoplay = autoplay;
		this.downscroll = downscroll;

		babyArrows = new FlxTypedGroup<BabyArrow>();
		add(babyArrows);

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
					babyArrow.animation.addByPrefix(BabyArrow.colors[index], 'arrow' + BabyArrow.actions[index].toUpperCase());
					babyArrow.animation.addByPrefix('static', 'arrow${BabyArrow.actions[index].toUpperCase()}');
					babyArrow.animation.addByPrefix('pressed', '${BabyArrow.actions[index]} press', 24, false);
					babyArrow.animation.addByPrefix('confirm', '${BabyArrow.actions[index]} confirm', 24, false);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
					babyArrow.antialiasing = true;
			}

			babyArrow.x += (index - ((4 / 2))) * BabyArrow.swagWidth;
			babyArrow.y -= 10;

			babyArrow.animation.play('static');
			babyArrows.add(babyArrow);

			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: babyArrow.defaultAlpha}, 1 / Conductor.songRate, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * index)});
		}

		splashes = new FlxTypedGroup<NoteSplash>();
		add(splashes);

		// cache the splash stuff
		var firework:NoteSplash = new NoteSplash(100, 100, 0);
		firework.alpha = 0.000001;
		splashes.add(firework);
	}

	public function popUpSplash(index:Int):Void
	{
		var firework:NoteSplash = splashes.recycle(NoteSplash);
		var babyArrow:BabyArrow = babyArrows.members[index];
		firework.setupNoteSplash(babyArrow.x, babyArrow.y, index);
		firework.alpha = 1;
		splashes.add(firework);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		splashes.forEachAlive(function(splash:NoteSplash)
		{
			var babyArrow:BabyArrow = babyArrows.members[splash.index];
			splash.setPosition(babyArrow.x, babyArrow.y);
			splash.scrollFactor.set(babyArrow.scrollFactor.x, babyArrow.scrollFactor.y);
			splash.angle = babyArrow.angle;
		});
	}
}
