package funkin.objects.ui.notes;

import funkin.backend.dependencies.FeatherTools.FeatherSprite;
import funkin.objects.ui.notes.BabyArrow;
import funkin.song.Conductor;
import funkin.states.PlayState;

class NoteTools
{
	// based on forever engine
	public static var quantIdx:Array<Int> = [4, 8, 12, 16, 20, 24, 32, 48, 64, 192];

	public static var defaultNotes:Array<String> = ['', 'mine', 'fake'];

	public static function declareQuant(step:Float):Int
	{
		for (q in 0...quantIdx.length)
		{
			//
		}

		return quantIdx.length - 1;
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
	public var doSplash:Bool = false;
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

	public var isQuant:Bool = false;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	public function new(step:Float, index:Int, type:String, ?prevNote:Note, isSustain:Bool = false):Void
	{
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		super(0, -2000);

		if (prevNote == null)
			prevNote = this;

		this.step = step;
		this.index = index;
		this.type = type;

		this.prevNote = prevNote;
		this.isSustain = isSustain;

		CustomAssets.generateNotes(this, index, isSustain);

		updateHitbox();

		if (!isSustain)
			playAnim(BabyArrow.colors[index] + "Scroll");
		else
		{
			earlyHitMult = 0.5;

			parentNote = prevNote;
			while (parentNote.isSustain && parentNote.prevNote != null)
				parentNote = parentNote.prevNote;
			parentNote.children.push(this);
		}

		if (isSustain && prevNote != null)
		{
			alpha = 0.6;
			speed = prevNote.speed;

			offsetX = width / 2;

			playAnim(BabyArrow.colors[index] + 'holdend');
			updateHitbox();

			offsetX -= width / 2;
			if (PlayState.assetSkin == 'pixel')
				offsetX += 30;

			if (prevNote.isSustain)
			{
				prevNote.playAnim(BabyArrow.colors[index] + 'hold');
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.song.speed;
				prevNote.updateHitbox();
			}
		}
	}

	override function update(elapsed:Float):Void
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
