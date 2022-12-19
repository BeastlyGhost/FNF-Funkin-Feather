package funkin.objects.ui.notes;

import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.essentials.song.Conductor;

/**
	Strumline class, initializes the gray notes at the top / bottom of the screen,
	it also comes with a set of functions for handling said notes
**/
class Strum extends FlxGroup
{
	public var characters:Array<Character>;

	public var babyArrows:FlxTypedGroup<BabyArrow>;

	public var notes:FlxTypedGroup<Note>;
	public var holds:FlxTypedGroup<Note>;
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

		notes = new FlxTypedGroup<Note>();
		holds = new FlxTypedGroup<Note>();

		if (OptionsAPI.getPref("Note Splash Opacity") > 0)
			splashes = new FlxTypedGroup<NoteSplash>();

		for (index in 0...4)
		{
			var babyArrow:BabyArrow = new BabyArrow(index);

			babyArrow.setPosition(x, y);
			babyArrow.ID = index;

			FunkinAssets.generateStrums(babyArrow, index);

			babyArrow.x += (index - ((4 / 2))) * babyArrow.swagWidth;
			babyArrow.y -= 10;

			babyArrow.animation.play('static');
			babyArrows.add(babyArrow);

			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: babyArrow.defaultAlpha}, 1 / Conductor.songRate,
				{ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * index)});
		}

		add(babyArrows);
		if (splashes != null)
			add(splashes);
		add(notes);
		add(holds);

		// cache the splash stuff
		popUpSplash(0, true);
	}

	public function popUpSplash(index:Int = 0, ?cache:Bool = false):Void
	{
		if (splashes == null)
			return;

		var babyArrow:BabyArrow = babyArrows.members[index];

		if (cache)
		{
			var firework:NoteSplash = new NoteSplash(babyArrow.x, babyArrow.y, index);
			firework.alpha = 0.000001;
			splashes.add(firework);
		}
		else
		{
			var firework:NoteSplash = splashes.recycle(NoteSplash);
			firework.setupNoteSplash(babyArrow.x, babyArrow.y, index);
			firework.alpha = OptionsAPI.getPref("Note Splash Opacity") * 0.01;
			splashes.add(firework);
		}
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
