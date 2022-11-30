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
	var attachmentsContainer:FlxTypedGroup<FlxSprite>;
	var textContainer:FlxTypedGroup<FlxText>;

	var difficultySpr:FlxSprite;

	var weekList:Array<WeekData> = [];

	var scoreTxt:FlxText;
	var nameTxt:FlxText;

	override function create()
	{
		super.create();

		DiscordRPC.update("STORY MENU", "Choosing a Week");

		FeatherUtils.menuMusicCheck(false);

		// oop
		persistentUpdate = persistentDraw = true;

		// initialize groups;
		weekContainer = new FlxTypedGroup<WeekItem>();
		textContainer = new FlxTypedGroup<FlxText>();
		attachmentsContainer = new FlxTypedGroup<FlxSprite>();
		characterContainer = new FlxTypedGroup<WeekCharacter>();

		scoreTxt = new FlxText(10, 10, 0, "SCORE: 69420", 36);
		scoreTxt.setFormat(AssetHandler.grabAsset("vcr", FONT, "data/fonts"), 32);

		nameTxt = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		nameTxt.setFormat(AssetHandler.grabAsset("vcr", FONT, "data/fonts"), 32, 0xFF000000, RIGHT);
		nameTxt.alpha = 0.7;

		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		add(textContainer);

		var blackBar:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, 0xFF000000);
		add(blackBar);

		add(attachmentsContainer);

		for (i in 0...weekList.length) {}
		add(weekContainer);

		/*
			var arrowL:FlxSprite = generateArrow(weekContainer.members[0].x + weekContainer.members[0].width + 10, textContainer.members[0].y + 10, 'left');

			difficultySpr = new FlxSprite(arrowL.x + 130, arrowL.y);

			var arrowR:FlxSprite = generateArrow(difficultySpr.x + difficultySpr.width + 50, arrowL.y, 'right');

			attachmentsContainer.add(arrowL);
			attachmentsContainer.add(difficultySpr);
			attachmentsContainer.add(arrowR);
		 */

		add(yellowBG);
		add(characterContainer);
	}

	function generateArrow(x:Float, y:Float, dir:String)
	{
		var arrow:FlxSprite = new FlxSprite(x, y);
		arrow.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		arrow.animation.addByPrefix('idle', 'arrow $dir');
		arrow.animation.addByPrefix('press', "arrow push $dir", 24, false);
		arrow.animation.play('idle');
		return arrow;
	}

	override function update(elapsed:Float)
	{
		if (Controls.getPressEvent("back"))
			MusicState.switchState(new MainMenu());
	}
}
