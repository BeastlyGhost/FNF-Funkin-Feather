package fnf.states.substates;

import feather.BaseMenu.BaseSubMenu;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import fnf.objects.ui.Alphabet;

class WarningSubstate extends BaseSubMenu {
	private var centerWarn:Alphabet;

	private var warningText:String;
	private var yesText:String = 'YES';
	private var noText:String = 'NO';

	private var fire:Void->Void;
	private var unfire:Void->Void;

	public override function new(warningText:String, yesText:String, noText:String, ?fire:Void->Void, ?unfire:Void->Void):Void {
		super();

		this.warningText = warningText;
		this.yesText = yesText;
		this.noText = noText;

		this.fire = fire;
		this.unfire = unfire;
	}

	override function create():Void {
		super.create();

		centerWarn = generateWarning(warningText);
		itemContainer = generateOptions(yesText, noText);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.scrollFactor.set();
		bg.alpha = 0;
		add(bg);

		FlxTween.tween(bg, {alpha: 0.5}, 0.6, {ease: FlxEase.sineOut});

		add(centerWarn);
		add(itemContainer);

		wrappableGroup = itemContainer.members;

		updateSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		updateSelection(Controls.isJustPressed("up") ? -1 : Controls.isJustPressed("down") ? 1 : 0);

		if (Controls.isJustPressed("accept")) {
			if (selection == 0) {
				if (fire != null)
					fire();
				else
					close();
			}

			if (selection == 1) {
				if (unfire != null)
					unfire();
				else
					close();
			}
		}
	}

	public override function updateSelection(newSelection:Int = 0):Void {
		super.updateSelection(newSelection);

		if (newSelection != 0)
			FSound.playSound("scrollMenu", 'sounds/menus');
	}

	private function generateWarning(text:String = "TEST"):Alphabet {
		var warning:Alphabet = new Alphabet(0, 100, text, false);
		warning.scrollFactor.set();
		warning.screenCenter(X);
		return warning;
	}

	private function generateOptions(yesTxt:String = "YES", noTxt:String = "NO"):FlxTypedGroup<Alphabet> {
		var retgroup:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();

		var yesBttn:Alphabet = new Alphabet(0, 320, yesTxt, false);
		var noBttn:Alphabet = new Alphabet(0, 420, noTxt, false);

		yesBttn.scrollFactor.set();
		noBttn.scrollFactor.set();
		yesBttn.screenCenter(X);
		noBttn.screenCenter(X);

		retgroup.add(yesBttn);
		retgroup.add(noBttn);

		return retgroup;
	}
}
