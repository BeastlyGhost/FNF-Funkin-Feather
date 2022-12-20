package funkin.states.editors;

import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.essentials.song.MusicState;
import funkin.objects.ui.menus.WeekCharacter;
import funkin.objects.ui.menus.WeekItem;

class WeekEditor extends MusicBeatState
{
	var weekContainer:FlxTypedGroup<WeekItem>;
	var characterContainer:FlxTypedGroup<WeekCharacter>;
}
