package objects.ui;

import base.song.Conductor;
import base.utils.FeatherUtils.FeatherSprite;
import base.utils.PlayerUtils;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRect;
import objects.ui.Strum.BabyArrow;
import states.PlayState;

/**
	Notefield class, initializes *scrolling* note handling,
	like spawning, sorting, and sprite clipping
**/
class Notefield extends FlxTypedGroup<Note>
{
	public function updateRects(note:Note, strum:Strum)
	{
		note.y = (strum.y - (Conductor.songPosition - note.strumTime) * (0.45 * note.speed));

		// i am so fucking sorry for this if condition
		if (note.isSustain
			&& note.y + note.offset.y <= strum.y + BabyArrow.swagWidth / 2
			&& (!note.mustPress || (note.wasGoodHit || (note.prevNote.wasGoodHit && !note.canBeHit))))
		{
			var swagRect = new FlxRect(0, strum.y + BabyArrow.swagWidth / 2 - note.y, note.width * 2, note.height * 2);
			swagRect.y /= note.scale.y;
			swagRect.height -= swagRect.y;

			note.clipRect = swagRect;
		}
	}

	public function removeNote(note:Note)
	{
		if (!note.canDie)
			return;

		note.active = false;
		note.exists = false;

		if (members.contains(note))
			remove(note, true);

		note.kill();
		note.destroy();
	}
}

class NoteSplash extends FeatherSprite
{
	public function new(x:Float, y:Float, index:Int = 0)
	{
		super(x, y);

		frames = AssetHandler.grabAsset("noteSplashes", SPARROW, "images/ui/default");

		animation.addByPrefix('note1-0', 'note impact 1 blue', 24, false);
		animation.addByPrefix('note2-0', 'note impact 1 green', 24, false);
		animation.addByPrefix('note0-0', 'note impact 1 purple', 24, false);
		animation.addByPrefix('note3-0', 'note impact 1 red', 24, false);
		animation.addByPrefix('note1-1', 'note impact 2 blue', 24, false);
		animation.addByPrefix('note2-1', 'note impact 2 green', 24, false);
		animation.addByPrefix('note0-1', 'note impact 2 purple', 24, false);
		animation.addByPrefix('note3-1', 'note impact 2 red', 24, false);

		setupNoteSplash(x, y, index);
	}

	public function setupNoteSplash(x:Float, y:Float, ?index:Int = 0)
	{
		setPosition(x, y);
		animation.play('note' + index + '-' + FlxG.random.int(0, 1), true);
		animation.curAnim.frameRate += FlxG.random.int(-2, 2);
		updateHitbox();
		offset.set(60, 30);
	}

	override public function update(elapsed:Float)
	{
		if (animation.curAnim.finished)
			kill();

		super.update(elapsed);
	}
}

/**
	Note class, initializes *scrolling* notes for the main game
**/
class Note extends FeatherSprite
{
	public var canBeHit:Bool = false;
	public var mustPress:Bool = false;
	public var wasGoodHit:Bool = false;
	public var canDie:Bool = true;
	public var tooLate:Bool = false;

	public var lowPriority:Bool = false;
	public var ignoreNote:Bool = false;
	public var isMine:Bool = false;

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
		var stringSect = babyArrow.getColor(index);

		switch (PlayState.assetSkin)
		{
			case "pixel":
				var indexPixel:Array<Int> = [4, 5, 6, 7];

				if (!isSustain)
				{
					loadGraphic(AssetHandler.grabAsset('NOTE_assets', IMAGE, 'images/ui/pixel'));
					animation.add(stringSect + 'Scroll', [indexPixel[index]], 12);
				}
				else
				{
					loadGraphic(AssetHandler.grabAsset('HOLD_assets', IMAGE, 'images/ui/pixel'));
					animation.add(stringSect + 'holdend', [indexPixel[index]]);
					animation.add(stringSect + 'hold', [indexPixel[index] - 4]);
				}

				babyArrow.setGraphicSize(Std.int(babyArrow.width * PlayState.pixelAssetSize));
				babyArrow.updateHitbox();
				babyArrow.antialiasing = false;

			default:
				frames = AssetHandler.grabAsset('NOTE_assets', SPARROW, 'images/ui/default');

				animation.addByPrefix(stringSect + 'Scroll', stringSect + '0');
				animation.addByPrefix(stringSect + 'hold', stringSect + ' hold piece');
				animation.addByPrefix(stringSect + 'holdend', stringSect + ' hold end');

				// i'm going after phantomarcade @BeastlyGhost
				animation.addByPrefix('purpleholdend', 'pruple end hold');

				setGraphicSize(Std.int(width * 0.7));
				antialiasing = true;
		}

		x += BabyArrow.swagWidth * index;

		updateHitbox();

		if (!isSustain)
			playAnim(stringSect + "Scroll");

		if (isSustain && prevNote != null)
		{
			alpha = 0.6;

			speed = prevNote.speed;

			x += width / 2;
			playAnim(stringSect + 'holdend');
			updateHitbox();

			if (prevNote.isSustain)
			{
				prevNote.playAnim(stringSect + 'hold');
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.song.speed;
				prevNote.updateHitbox();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			if (strumTime > Conductor.songPosition - PlayerUtils.timingThreshold
				&& strumTime < Conductor.songPosition + PlayerUtils.timingThreshold)
				canBeHit = true;
			else
				canBeHit = true;
		}
		else
			canBeHit = false;

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
