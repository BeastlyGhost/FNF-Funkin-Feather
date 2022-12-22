package funkin.objects.ui.notes;

import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.essentials.song.Conductor;
import funkin.objects.ui.notes.Note.NoteSplash;

/**
	`BabyArrow`s are sprites that are attached to your `Strum`line,
	this class simply initializes said `BabyArrow`s
**/
class BabyArrow extends PlumaSprite
{
	public var swagWidth:Float = 160 * 0.7;

	public static var actions:Array<String> = ['left', 'down', 'up', 'right'];
	public static var colors:Array<String> = ['purple', 'blue', 'green', 'red'];

	/**
		for Feather Notesplashes
		will eventually be used for the notes themselves
	**/
	public static var colorPresets:Map<String, Array<Int>> = [
		"default" => [0xFFC24C9A, 0xFF03FFFF, 0xFF12FA05, 0xFFF9393F],
		"pixel" => [0xFFE276FF, 0xFF3DCAFF, 0xFF71E300, 0xFFFF884E],
	];

	public var index:Int = 0;

	public var defaultAlpha:Float = 0.8;

	public var glowsOnHit:Bool = true;

	public function new(index:Int):Void
	{
		super(x, y);

		alpha = defaultAlpha;

		this.index = index;

		updateHitbox();
		scrollFactor.set();
	}

	public override function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		super.playAnim(AnimName);

		centerOffsets();
		centerOrigin();
	}
}

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
			var babyArrow:BabyArrow = babyArrows.members[splash.ID];
			splash.setPosition(babyArrow.x, babyArrow.y);
			splash.scrollFactor.set(babyArrow.scrollFactor.x, babyArrow.scrollFactor.y);
			splash.angle = babyArrow.angle;
		});
	}
}
