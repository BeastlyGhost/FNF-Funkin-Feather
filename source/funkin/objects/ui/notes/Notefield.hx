package funkin.objects.ui.notes;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRect;
import funkin.objects.ui.notes.Strum.BabyArrow;
import funkin.song.Conductor;

/**
	Notefield class, initializes *scrolling* note handling,
	like spawning, sorting, and sprite clipping
**/
class Notefield extends FlxTypedGroup<Note>
{
	public function updateRects(note:Note, strum:Strum)
	{
		note.y = (strum.y - (Conductor.songPosition - note.step) * (0.45 * note.speed));

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
