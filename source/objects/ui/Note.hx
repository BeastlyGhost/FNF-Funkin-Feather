package objects.ui;

import base.song.Conductor;
import base.utils.FeatherUtils.FeatherSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import objects.ui.Strum.BabyArrow;

class Notefield extends FlxTypedGroup<Note>
{
	// TODO: move sorting and looping through note functions here
}

class Note extends FeatherSprite
{
	public var canBeHit:Bool = false;
	public var mustPress:Bool = false;
	public var wasGoodHit:Bool = false;
	public var canDie:Bool = true;
	public var tooLate:Bool = false;

	public var type:String = 'default';
	public var prevNote:Note;

	public var speed:Float = 1;
	public var strumTime:Float = 0;
	public var index:Int = 0;

	public var sustainLength:Float = 0;
	public var isSustain:Bool = false;

	public function new(strumTime:Float, index:Int, type:String, ?prevNote:Note, isSustain:Bool = false)
	{
		super(x, y);

		if (prevNote == null)
			prevNote = this;

		this.type = type;
		this.strumTime = strumTime;
		this.index = index;

		this.prevNote = prevNote;
		this.isSustain = isSustain;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		generateNote();
	}

	public function generateNote()
	{
		var babyArrow:BabyArrow = new BabyArrow(index);

		frames = AssetHandler.grabAsset('NOTE_assets', SPARROW, 'images/ui/default');

		animation.addByPrefix(babyArrow.getColor(index) + 'Scroll', babyArrow.getColor(index) + '0');
		animation.addByPrefix(babyArrow.getColor(index) + 'hold', babyArrow.getColor(index) + ' hold piece');
		animation.addByPrefix(babyArrow.getColor(index) + 'holdend', babyArrow.getColor(index) + ' hold end');

		// i'm going after phantomarcade @BeastlyGhost
		animation.addByPrefix('purpleholdend', 'pruple end hold');

		antialiasing = true;

		x += babyArrow.swagWidth * index;

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();

		if (!isSustain)
			playAnim(babyArrow.getColor(index) + "Scroll");

		if (isSustain && prevNote != null)
		{
			alpha = 0.6;

			speed = prevNote.speed;

			x += width / 2;
			playAnim(babyArrow.getColor(index) + 'holdend');
			updateHitbox();

			if (prevNote.isSustain)
			{
				prevNote.playAnim(babyArrow.getColor(index) + 'hold');
				// prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.song.speed;
				prevNote.updateHitbox();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			if (!wasGoodHit)
			{
				tooLate = true;
				canBeHit = false;
			}
			else
			{
				if (strumTime > Conductor.songPosition /* - ScoreUtils.safeZoneOffset*/)
					if (strumTime < Conductor.songPosition + 0.5 /* * ScoreUtils.safeZoneOffset*/)
						canBeHit = true;
					else
						canBeHit = true;
			}
		}
		else
		{
			canBeHit = false;
			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
