package funkin.objects.ui.notes;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRect;
import funkin.states.PlayState;
import funkin.objects.ui.notes.BabyArrow;
import funkin.song.Conductor;

/**
	Notefield class, initializes *scrolling* note handling,
	like spawning, sorting, and sprite clipping
**/
class Notefield extends FlxTypedGroup<Note>
{
	public function updatePosition(note:Note, strumline:Strumline):Void
	{
		var babyArrow:BabyArrow = strumline.babyArrows.members[note.index];

		note.x = babyArrow.x;

		var center:Float = babyArrow.y + BabyArrow.swagWidth / 2;
		note.y = babyArrow.y - (Conductor.songPosition - note.step) * (0.45 * note.speed);

		if (note.isSustain)
		{
			note.flipY = strumline.downscroll;

			if (strumline.downscroll)
			{
				if (note.animation.curAnim.name.endsWith('end') && note.prevNote != null)
					note.y += note.prevNote.height;
				else
					note.y += note.height / 2;

				if (note.y - note.offset.y * note.scale.y + note.height >= center
					&& (!note.mustPress || (note.wasGoodHit || (note.prevNote.wasGoodHit && !note.canBeHit))))
				{
					var swagRect = new FlxRect(0, 0, note.frameWidth, note.frameHeight);
					swagRect.height = (center - note.y) / note.scale.y;
					swagRect.y = note.frameHeight - swagRect.height;

					note.clipRect = swagRect;
				}
			}
			else if (note.y + note.offset.y * note.scale.y <= center
				&& (!note.mustPress || (note.wasGoodHit || (note.prevNote.wasGoodHit && !note.canBeHit))))
			{
				var swagRect = new FlxRect(0, 0, note.width / note.scale.x, note.height / note.scale.y);
				swagRect.y = (center - note.y) / note.scale.y;
				swagRect.height -= swagRect.y;

				note.clipRect = swagRect;
			}
		}
	}

	public function removeNote(note:Note):Void
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
