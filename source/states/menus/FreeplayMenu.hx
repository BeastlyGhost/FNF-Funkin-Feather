package states.menus;

import base.song.MusicState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import objects.Alphabet;
import sys.thread.Mutex;
import sys.thread.Thread;

typedef SongMetadata =
{
	var name:String;
	var week:Int;
	var character:String;
	var color:Int; // should this be an array? huh.. @BeastlyGhost
}

/**
	the Freeplay Menu, for selecting and playing songs!

	when selecting songs here, things like the Chart Editor will be allowed during gameplay
**/
class FreeplayMenu extends MusicBeatState
{
	var itemContainer:FlxTypedGroup<Alphabet>;
	var songList:Array<SongMetadata> = [];

	var difficultySelection:Int = -1;
	var songInst:FlxSound;
	var songVocals:FlxSound;

	var mutex:Mutex;
}
