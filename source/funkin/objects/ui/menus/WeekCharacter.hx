package funkin.objects.ui.menus;

import flixel.FlxSprite;
import sys.FileSystem;

typedef WeekCharacterData =
{
	var image:String;
	var scale:Float;
	var position:Array<Int>;
	var idleAnim:Array<Dynamic>;
	var heyAnim:Array<Dynamic>;
	var flipX:Bool;
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
