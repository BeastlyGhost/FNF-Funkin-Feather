package funkin.states.editors;

import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.objects.ui.menus.WeekCharacter;
import funkin.objects.ui.menus.WeekItem;
import funkin.essentials.song.MusicState;

class WeekEditor extends MusicBeatState
{
	var weekContainer:FlxTypedGroup<WeekItem>;
	var characterContainer:FlxTypedGroup<WeekCharacter>;
}
