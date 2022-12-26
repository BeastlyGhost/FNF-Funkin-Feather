package fnf.objects.menus;

import flixel.FlxSprite;
import sys.FileSystem;

typedef WeekCharacterData = {
	var image:String;
	var scale:Float;
	var position:Array<Int>;
	var animations:{
		var idle:Array<Dynamic>;
		var confirm:Array<Dynamic>;
	};
	var flipX:Bool;
}

class WeekCharacter extends FlxSprite {
	var charData:WeekCharacterData;

	var baseX:Float = 0;
	var baseY:Float = 0;

	public function new(x:Float, char:String = 'bf'):Void {
		super(x);

		baseX = x;
		baseY = y;

		createCharacter(char);
	}

	public function createCharacter(char:String = 'bf'):Void {
		var pathRaw = AssetHelper.grabAsset(char, YAML, "images/menus/story/characters");

		var yamlRaw = null;
		if (FileSystem.exists(pathRaw))
			yamlRaw = pathRaw;

		if (yamlRaw == null)
			return;

		charData = Yaml.read(yamlRaw, yaml.Parser.options().useObjects());

		try
			frames = AssetHelper.grabAsset(charData.image, SPARROW, "images/menus/story/characters")
		catch (e:Dynamic)
			frames = null;

		if (char != null || char != '') {
			if (!visible)
				visible = true;

			if (frames != null) {
				animation.addByPrefix('idle', charData.animations.idle[0], charData.animations.confirm[1], charData.animations.confirm[2]);

				if (charData.animations.confirm != null)
					animation.addByPrefix('hey', charData.animations.confirm[0], charData.animations.confirm[1], charData.animations.confirm[2]);

				animation.play('idle');

				setGraphicSize(Std.int(width * charData.scale));
				setPosition(baseX + charData.position[0], baseY + charData.position[1]);
				updateHitbox();
			}

			flipX = charData.flipX;
		} else
			visible = false;
	}
}
