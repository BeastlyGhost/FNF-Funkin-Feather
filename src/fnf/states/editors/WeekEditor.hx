package fnf.states.editors;

import flixel.group.FlxGroup.FlxTypedGroup;
import fnf.objects.menus.WeekCharacter;
import fnf.objects.menus.WeekItem;
import fnf.song.MusicState;

class WeekEditor extends MusicBeatState {
	var weekContainer:FlxTypedGroup<WeekItem>;
	var characterContainer:FlxTypedGroup<WeekCharacter>;
}
