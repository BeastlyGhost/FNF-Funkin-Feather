package states.menus;

import base.song.MusicState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import objects.ui.menus.WeekCharacter;
import objects.ui.menus.WeekItem;

typedef WeekData =
{
	var weekImage:String;
	var storyName:String;
	var songs:Array<WeekSongData>;
	var characters:Array<String>;
	var difficulties:Array<String>;
	var hideFromStory:Bool;
	var hideFromFreeplay:Bool;
	var defaultLocked:Bool;
}

typedef WeekSongData =
{
	var name:String;
	var character:String;
	var colors:Array<Int>; // for freeplay
}

class StoryMenu extends MusicBeatState
{
	var weekContainer:FlxTypedGroup<WeekItem>;
	var characterContainer:FlxTypedGroup<WeekCharacter>;

	var weekList:Array<WeekData> = [];

	var scoreTxt:FlxText;
	var nameTxt:FlxText;

	override function create()
	{
		super.create();

		DiscordRPC.update("STORY MENU", "Choosing a Week");

		FeatherUtils.menuMusicCheck(false);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF123456);
		add(bg);

		characterContainer = new FlxTypedGroup<WeekCharacter>();
		add(characterContainer);

		var char:WeekCharacter = new WeekCharacter((FlxG.width * 0.25) * 1 - 150, 'bf');
		characterContainer.add(char);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ANY)
			MusicState.switchState(new MainMenu());
	}
}
