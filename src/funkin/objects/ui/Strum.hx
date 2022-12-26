package funkin.objects.ui;

import flixel.group.FlxGroup;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.essentials.song.Conductor;
import funkin.objects.ui.Note;

/**
	Strumline class, initializes the gray notes at the top / bottom of the screen,
	it also comes with a set of functions for handling said notes
**/
class Strum extends FlxGroup {
	public var characters:Array<Character>;

	public var babyArrows:FlxTypedGroup<BabyArrow>;

	public var notes:FlxTypedGroup<Note>;
	public var holds:FlxTypedGroup<Note>;
	public var allNotes:FlxTypedGroup<Note>;
	public var splashes:FlxTypedGroup<Splash>;

	public var downscroll:Bool = false;
	public var autoplay:Bool = true;

	public function new(x:Float, y:Float, type:String = 'default', characters:Array<Character>, autoplay:Bool = true, downscroll:Bool = false):Void {
		super();

		this.characters = characters;
		this.autoplay = autoplay;
		this.downscroll = downscroll;

		babyArrows = new FlxTypedGroup<BabyArrow>();

		notes = new FlxTypedGroup<Note>();
		holds = new FlxTypedGroup<Note>();
		allNotes = new FlxTypedGroup<Note>();

		if (OptionsAPI.getPref("Splash Opacity") != null && OptionsAPI.getPref("Splash Opacity") > 0)
			splashes = new FlxTypedGroup<Splash>();

		for (index in 0...4) {
			var babyArrow:BabyArrow = new BabyArrow(index);

			babyArrow.setPosition(x, y);
			babyArrow.ID = index;

			FunkinAssets.generateStrums(babyArrow, index, (type == 'pixel' ? 'pixel_notes' : 'NOTE_assets'));

			babyArrow.x += (index - ((4 / 2))) * babyArrow.swagWidth;
			babyArrow.y -= 10;

			babyArrow.angle = (index == 0 ? -90 : index == 3 ? 90 : index == 1 ? 180 : 0);

			babyArrow.playAnim('static');
			babyArrows.add(babyArrow);

			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: babyArrow.defaultAlpha}, 1 / Conductor.songRate,
				{ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * index)});
		}

		if (OptionsAPI.getPref("Holds behind Receptors"))
			add(holds);
		add(babyArrows);
		if (splashes != null)
			add(splashes);
		add(notes);
		if (!OptionsAPI.getPref("Holds behind Receptors"))
			add(holds);

		// cache the splash stuff
		popUpSplash(0, 0, type, true);
	}

	public function popUpSplash(index:Int = 0, step:Float = 0, type:String = 'default', ?cache:Bool = false):Void {
		if (splashes == null)
			return;

		var babyArrow:BabyArrow = babyArrows.members[index];

		if (cache) {
			var firework:Splash = new Splash(babyArrow.x, babyArrow.y, index);
			firework.alpha = 0.000001;
			splashes.add(firework);
		} else {
			var preset:String = type;
			if (OptionsAPI.getPref("Quant Style").toLowerCase() != 'none')
				preset = 'quants-' + OptionsAPI.getPref("Quant Style").toLowerCase();

			var firework:Splash = splashes.recycle(Splash);
			firework.setupNoteSplash(babyArrow.x, babyArrow.y, index, step, preset);
			firework.alpha = OptionsAPI.getPref("Splash Opacity") * 0.01;
			splashes.add(firework);
		}
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);
		if (splashes != null) {
			splashes.forEachAlive(function(splash:Splash) {
				var babyArrow:BabyArrow = babyArrows.members[splash.ID];
				splash.setPosition(babyArrow.x, babyArrow.y);
				splash.scrollFactor.set(babyArrow.scrollFactor.x, babyArrow.scrollFactor.y);
				splash.angle = babyArrow.angle;
			});
		}
	}

	public function updatePosition(note:Note, strum:Strum):Void {
		var babyArrow:BabyArrow = strum.babyArrows.members[note.index];

		note.x = babyArrow.x + note.noteDisplace.x;

		var strumY:Float = babyArrow.y + note.noteDisplace.x;
		var center:Float = strumY + babyArrow.swagWidth / 2;
		note.y = strumY - (Conductor.songPosition - note.step) * (0.45 * note.speed) * (strum.downscroll ? -1 : 1);

		if (note.isSustain) {
			note.flipY = strum.downscroll;
			note.holdDisplace.x = 50;

			if (strum.downscroll) {
				if (note.animation.curAnim.name.endsWith('end') && note.prevNote != null)
					note.y += note.prevNote.height;
				else
					note.y += note.height;

				if (note.y - note.offset.y * note.scale.y + note.height >= center
					&& (!note.noteData.mustPress
						|| (note.noteData.wasGoodHit || (note.prevNote.noteData.wasGoodHit && !note.noteData.canBeHit)))) {
					var swagRect = new FlxRect(0, 0, note.frameWidth, note.frameHeight);
					swagRect.height = (center - note.y) / note.scale.y;
					swagRect.y = note.frameHeight - swagRect.height;

					note.clipRect = swagRect;
				}
			} else if (note.y + note.offset.y * note.scale.y <= center
				&& (!note.noteData.mustPress
					|| (note.noteData.wasGoodHit || (note.prevNote.noteData.wasGoodHit && !note.noteData.canBeHit)))) {
				var swagRect = new FlxRect(0, 0, note.width / note.scale.x, note.height / note.scale.y);
				swagRect.y = (center - note.y) / note.scale.y;
				swagRect.height -= swagRect.y;

				note.clipRect = swagRect;
			}
		}
	}

	public function addNote(note:Note):Void {
		if (note.isSustain)
			holds.add(note);
		else
			notes.add(note);
		allNotes.add(note);
	}

	public function removeNote(note:Note):Void {
		if (!note.typeData.canDie)
			return;

		note.active = false;
		note.exists = false;

		var group:FlxTypedGroup<Note> = (note.isSustain ? holds : notes);

		if (group.members.contains(note)) {
			group.remove(note);
			allNotes.remove(note);
		}

		note.kill();
		note.destroy();
	}
}
