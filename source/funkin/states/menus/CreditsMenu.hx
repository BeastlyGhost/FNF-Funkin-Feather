package funkin.states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.objects.ui.fonts.Alphabet;
import funkin.song.MusicState;

typedef CreditsData =
{
	var mainBG:String;
	var mainBGColor:String;
	var shouldChangeColor:Bool;
	var userList:Array<CreditsUserData>;
}

typedef CreditsUserData =
{
	var name:String;
	var type:String;
	var icon:String;
	var profession:String;
	var description:String;
	var socials:Array<Array<String>>;
}

class CreditsMenu extends MusicBeatState
{
	var itemContainer:FlxTypedGroup<Alphabet>;
	var iconContainer:Array<FeatherAttachedSprite> = [];

	var creditsData:CreditsData;
	var menuBG:FlxSprite;

	override function create()
	{
		super.create();

		creditsData = Yaml.read(AssetHandler.grabAsset("credits", YAML, "data/menus"), yaml.Parser.options().useObjects());

		DiscordRPC.update("CREDITS MENU", "Reading through Descriptions.");

		FeatherTools.menuMusicCheck(false);

		menuBG = new FlxSprite(-80).loadGraphic(AssetHandler.grabAsset('menuDesat', IMAGE, 'images/menus'));
		menuBG.scrollFactor.set();
		menuBG.screenCenter(X);
		add(menuBG);

		itemContainer = new FlxTypedGroup<Alphabet>();
		add(itemContainer);

		for (i in 0...creditsData.userList.length)
		{
			var userCredits = creditsData.userList[i];

			var personText:Alphabet = new Alphabet(0, 0, userCredits.name, true);

			if (userCredits.type == null)
				userCredits.type = "person";

			if (userCredits.type == "separator" || userCredits.type == "divider")
			{
				personText.screenCenter(X);
				personText.forceX = personText.x;
				personText.displacement.y = -55;
				personText.scrollFactor.set();
			}
			else
			{
				personText.screenCenter();
				personText.y = (125 * (i - Math.floor(creditsData.userList.length / 2)));
			}

			personText.targetY = i;
			personText.isMenuItem = true;
			personText.displacement.x = 100;
			personText.alpha = 0.6;

			itemContainer.add(personText);

			if (userCredits.icon != null || userCredits.icon.length > 1)
			{
				var personIcon:FeatherAttachedSprite = new FeatherAttachedSprite(userCredits.icon, 'images/menus/creditsMenu');
				personIcon.parentSprite = personText;
				personIcon.addX = -50;
				personIcon.addY = -30;
				iconContainer.push(personIcon);
				add(personIcon);
			}
		}

		wrappableGroup = creditsData.userList;

		updateSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Controls.isJustPressed("up"))
			updateSelection(-1);
		if (Controls.isJustPressed("down"))
			updateSelection(1);

		if (Controls.isJustPressed("accept")) {}

		if (Controls.isJustPressed("back"))
		{
			MusicState.switchState(new MainMenu());
			FlxG.sound.play(AssetHandler.grabAsset('cancelMenu', SOUND, "sounds/menus"));
		}
	}

	override public function updateSelection(newSelection:Int = 0):Void
	{
		super.updateSelection(newSelection);

		var selectionJumper:Int = ((newSelection < selection) ? -1 : 1);

		if (newSelection != 0)
			FlxG.sound.play(AssetHandler.grabAsset('scrollMenu', SOUND, "sounds/menus"));

		/*
			for (i in 0...iconContainer.length)
				iconContainer[i].alpha = 0.6;

			iconContainer[selection].alpha = 1;
		 */

		var blah:Int = 0;
		for (item in itemContainer.members)
		{
			item.targetY = blah - selection;
			blah++;

			item.alpha = 0.6;
			if (item.targetY == 0)
				item.alpha = 1;
		}

		/*
			if (wrappableGroup[selection].type != null && wrappableGroup[selection].type == "divider")
				updateSelection(selection + selectionJumper);
		 */
	}
}
