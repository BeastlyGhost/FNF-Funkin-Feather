package funkin.objects.ui.notes;

import feather.tools.FeatherTools.FeatherSprite;
import funkin.objects.ui.notes.BabyArrow;
import funkin.song.Conductor;
import funkin.states.PlayState;

// just to make it easier to add into note parameters and such
typedef DefaultNote =
{
	var canBeHit:Bool;
	var mustPress:Bool;
	var wasGoodHit:Bool;
	var tooLate:Bool;
}

typedef NoteType =
{
	var type:String;
	var lowPriority:Bool;
	var ignoreNote:Bool;
	var doSplash:Bool;
	var isMine:Bool;
	var canDie:Bool;
}

typedef NoteJudge =
{
	var earlyHitMult:Float;
	var lateHitMult:Float;
	var missOffset:Float;
}

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
	public var noteData:DefaultNote = {
		canBeHit: false,
		mustPress: false,
		wasGoodHit: false,
		tooLate: false
	};

	public var typeData:NoteType = {
		type: 'default',
		lowPriority: false,
		ignoreNote: false,
		doSplash: false,
		isMine: false,
		canDie: true
	};

	// modifiable gameplay variables
	public var judgeData:NoteJudge = {
		earlyHitMult: 1,
		lateHitMult: 1,
		missOffset: 200
	};

	public var babyInstance:BabyArrow;

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
		typeData.type = type;

		this.prevNote = prevNote;
		this.isSustain = isSustain;

		babyInstance = new BabyArrow(index);

		FunkinAssets.generateNotes(this, index, isSustain);

		updateHitbox();

		if (!isSustain)
			playAnim(BabyArrow.colors[index] + "Scroll");
		else
		{
			judgeData.earlyHitMult = 0.5;

			parentNote = prevNote;
			while (parentNote.isSustain && parentNote.prevNote != null)
				parentNote = parentNote.prevNote;
			parentNote.children.push(this);
		}

		if (isSustain && prevNote != null)
		{
			speed = prevNote.speed;
			alpha = 0.6;

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

		if (noteData.mustPress)
		{
			noteData.canBeHit = (step > Conductor.songPosition - Conductor.safeZoneOffset * judgeData.lateHitMult
				&& step < Conductor.songPosition + Conductor.safeZoneOffset * judgeData.earlyHitMult);
		}
		else
			noteData.canBeHit = false;

		if (noteData.tooLate || (prevNote != null && prevNote.isSustain && prevNote.noteData.tooLate))
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
