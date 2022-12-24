package funkin.objects.ui.notes;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRect;
import funkin.essentials.song.Conductor;
import funkin.objects.ui.notes.Note.BabyArrow;

/**
	Notefield class, initializes *scrolling* note handling,
	like spawning, sorting, and sprite clipping
**/
class Notefield extends FlxTypedGroup<Note> {
	public function updatePosition(note:Note, strum:Strum):Void {
		var babyArrow:BabyArrow = strum.babyArrows.members[note.index];

		note.x = babyArrow.x + note.offsetX;

		var strumY:Float = babyArrow.y + note.offsetY;
		var center:Float = strumY + babyArrow.swagWidth / 2;
		note.y = strumY - (Conductor.songPosition - note.step) * (0.45 * note.speed) * (strum.downscroll ? -1 : 1);

		if (note.isSustain) {
			note.flipY = strum.downscroll;

			if (strum.downscroll) {
				if (note.animation.curAnim.name.endsWith('end') && note.prevNote != null)
					note.y += note.prevNote.height;
				else
					note.y += note.height / 2;

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

	public function addNote(note:Note, strum:Strum):Void {
		if (note != null && strum != null) {
			if (!strum.notes.members.contains(note))
				strum.notes.add(note);
		}
	}

	public function removeNote(note:Note, ?container:Array<Note>):Void {
		if (!note.typeData.canDie)
			return;

		note.active = false;
		note.exists = false;

		if (members.contains(note))
			remove(note, true);

		if (container != null && container.contains(note))
			container.remove(note);

		note.kill();
		note.destroy();
	}
}
