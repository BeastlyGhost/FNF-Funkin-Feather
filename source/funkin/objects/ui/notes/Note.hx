package funkin.objects.ui.notes;

import funkin.backend.dependencies.FeatherTools.FeatherSprite;
import funkin.objects.ui.notes.BabyArrow;
import funkin.song.Conductor;
import funkin.states.PlayState;

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

	// modifiable gameplay variables
	public var earlyHitMult:Float = 1;
	public var lateHitMult:Float = 1;
	public var missOffset:Float = 200;

	public var type:String = 'default';
	public var prevNote:Note;
	public var parentNote:Note;
	public var children:Array<Note> = [];

	public var speed:Float = 1;
	public var step:Float = 0;
	public var index:Int = 0;

	public var sustainLength:Float = 0;
	public var isSustain:Bool = false;

	public function new(step:Float, index:Int, type:String, ?prevNote:Note, isSustain:Bool = false)
	{
		super(x, y);

		if (prevNote == null)
			prevNote = this;

		this.step = step;
		this.index = index;
		this.type = type;

		this.prevNote = prevNote;
		this.isSustain = isSustain;

		if (isSustain)
		{
			earlyHitMult = 0.5;

			parentNote = prevNote;
			while (parentNote.isSustain && parentNote.prevNote != null)
				parentNote = parentNote.prevNote;
			parentNote.children.push(this);
		}

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		generateNote();
	}

	public function generateNote()
	{
		var stringSect = BabyArrow.colors[index];

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

				setGraphicSize(Std.int(width * PlayState.pixelAssetSize));
				updateHitbox();
				antialiasing = false;

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
			canBeHit = step > Conductor.songPosition - Conductor.safeZoneOffset * lateHitMult
				&& step < Conductor.songPosition + Conductor.safeZoneOffset * earlyHitMult;
		else
			canBeHit = false;

		if (tooLate || (prevNote != null && prevNote.isSustain && prevNote.tooLate))
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
