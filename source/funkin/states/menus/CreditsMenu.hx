package funkin.states.menus;

import feather.BaseMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.objects.ui.fonts.Alphabet;
import funkin.essentials.song.MusicState;

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

class CreditsMenu extends BaseMenu
{
	var iconContainer:Array<ChildSprite> = [];
	var creditsData:CreditsData;

	override function create()
	{
		super.create();

		bgImage = 'menuDesat';

		creditsData = Yaml.read(AssetHelper.grabAsset("credits", YAML, "data/menus"), yaml.Parser.options().useObjects());

		DiscordRPC.update("CREDITS MENU", "Reading through Descriptions.");
		FeatherTools.menuMusicCheck(false);

		itemContainer = new FlxTypedGroup<Alphabet>();
		add(itemContainer);

		for (i in 0...creditsData.userList.length)
		{
			var userCredits = creditsData.userList[i];

			var personText:Alphabet = new Alphabet(0, 0, userCredits.name, false);

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
			personText.alpha = 0.6;

			itemContainer.add(personText);

			if (userCredits.icon != null || userCredits.icon.length > 1)
			{
				var personIcon:ChildSprite = new ChildSprite(userCredits.icon, 'images/menus/creditsMenu');
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

		updateSelection(Controls.isJustPressed("up") ? -1 : Controls.isJustPressed("down") ? 1 : 0);

		if (Controls.isJustPressed("accept")) {}

		if (Controls.isJustPressed("back"))
		{
			MusicState.switchState(new MainMenu());
			FSound.playSound("cancelMenu", "sounds/menus");
		}
	}

	override public function updateSelection(newSelection:Int = 0):Void
	{
		super.updateSelection(newSelection);

		var selectionJumper:Int = ((newSelection > selection) ? 1 : -1);

		if (newSelection != 0)
			FSound.playSound("scrollMenu", "sounds/menus");

		for (i in 0...iconContainer.length)
			if (iconContainer[i] != null)
				iconContainer[i].alpha = 0.6;

		if (iconContainer[selection] != null)
			iconContainer[selection].alpha = 1;

		// if (wrappableGroup[selection].type != null && wrappableGroup[selection].type == "divider")
		// 	updateSelection(selection + selectionJumper);
	}
}
