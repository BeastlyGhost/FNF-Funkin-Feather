package states.menus;

import base.song.MusicState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import sys.FileSystem;
import sys.io.File;

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

typedef WeekCharacterData =
{
	var image:String;
	var scale:Float;
	var position:Array<Int>;
	var idleAnim:Array<Dynamic>;
	var heyAnim:Array<Dynamic>;
	var flipX:Bool;
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

class WeekItem extends FlxSpriteGroup
{
	var itemY:Float = 0;
	var sprite:FlxSprite;
	var flashingVal:Int = 0;

	public function new(x:Float, y:Float, imageName:String = 'week0')
	{
		super(x, y);
		sprite = new FlxSprite().loadGraphic(AssetHandler.grabAsset(imageName, IMAGE, 'images/menus/storyMenu/weeks'));
		add(sprite);
	}

	var spriteActive:Bool = false;

	public function select()
		spriteActive = true;

	var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		y = FlxMath.lerp(y, (itemY * 120) + 480, 0.17);

		if (spriteActive)
			flashingVal += 1;

		if (flashingVal % fakeFramerate >= Math.floor(fakeFramerate / 2))
			sprite.color = 0xFF33ffff;
		else
			sprite.color = FlxColor.WHITE;
	}
}

class WeekCharacter extends FlxSprite
{
	var charData:WeekCharacterData;

	var baseX:Float = 0;
	var baseY:Float = 0;

	public function new(x:Float, char:String = 'bf')
	{
		super(x);

		baseX = x;
		baseY = y;

		createCharacter(char);
	}

	public function createCharacter(char:String = 'bf')
	{
		var pathRaw = AssetHandler.grabAsset(char, YAML, "images/menus/storyMenu/characters");

		var yamlRaw = null;
		if (FileSystem.exists(pathRaw))
			yamlRaw = pathRaw;

		if (yamlRaw == null)
			return;

		trace(yamlRaw);

		charData = cast Yaml.read(yamlRaw, yaml.Parser.options().useObjects());
		trace(charData.image);

		try
		{
			frames = AssetHandler.grabAsset(charData.image, SPARROW, "images/menus/storyMenu/characters");
		}
		catch (e)
		{
			frames = null;
		}

		if (char != null || char != '')
		{
			if (!visible)
				visible = true;

			if (frames != null)
			{
				animation.addByPrefix('idle', charData.idleAnim[0], charData.idleAnim[1], charData.idleAnim[2]);

				if (charData.heyAnim != null)
					animation.addByPrefix('hey', charData.heyAnim[0], charData.heyAnim[1], charData.heyAnim[2]);

				animation.play('idle');

				setGraphicSize(Std.int(width * charData.scale));
				setPosition(baseX + charData.position[0], baseY + charData.position[1]);
				updateHitbox();
			}

			flipX = charData.flipX;
		}
		else
			visible = false;
	}
}
