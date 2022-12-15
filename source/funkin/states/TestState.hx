package funkin.states;

import flixel.FlxG;
import flixel.FlxSprite;
import funkin.objects.ui.fonts.Alphabet;
import flixel.FlxState;
import funkin.objects.ui.menus.OptionThingie.SelectorThingie;
import funkin.song.MusicState;
import funkin.states.menus.MainMenu;

class TestState extends FlxState
{
	public var selector:SelectorThingie;

	override function create():Void
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFA74848);
		bg.scrollFactor.set();
		add(bg);

		var test = new Alphabet(0, 0, "Hello", true);
		test.color = 0xFFFFFFFF;
		test.screenCenter(XY);
		add(test);

		var pref = OptionsAPI.getPref("User Interface Style", false);

		selector = new SelectorThingie(0, 0, pref.name, pref.values);
		selector.screenCenter(XY);
		add(selector);
	}

	override function update(elapsed:Float):Void
	{
		if (Controls.isJustPressed("back"))
			MusicState.switchState(new MainMenu());

		var rightPress:Bool = Controls.isJustPressed("right");
		if (Controls.isJustPressed("left") || rightPress)
			selector.changeArrow(rightPress);
	}
}
