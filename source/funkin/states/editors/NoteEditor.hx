package funkin.states.editors;

import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.essentials.song.MusicState;
import funkin.objects.ui.notes.Note;

class NoteEditor extends MusicBeatSubstate {
	public var notes:FlxTypedGroup<Note>;

	public override function create():Void {
		super.create();

		notes = new FlxTypedGroup<Note>();

		for (index in 0...4) {
			var note:Note = new Note(0, index, 'default');
			note.screenCenter(X);
			notes.add(note);
		}

		add(notes);
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (Controls.isJustPressed("back"))
			close();
	}

	public override function close():Void {
		OptionsAPI.savePrefs();
		super.close();
	}
}
