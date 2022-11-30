package states.editors;

import base.song.MusicState;
import flixel.group.FlxGroup.FlxTypedGroup;
import objects.ui.menus.WeekCharacter;
import objects.ui.menus.WeekItem;

class WeekEditor extends MusicBeatState
{
	var weekContainer:FlxTypedGroup<WeekItem>;
	var characterContainer:FlxTypedGroup<WeekCharacter>;
}
