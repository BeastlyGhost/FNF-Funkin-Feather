package funkin.objects.ui.menus;

import feather.tools.FeatherModule;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.objects.ui.fonts.Alphabet;
import sys.FileSystem;

class CheckboxThingie extends FeatherSprite
{
	public var parentSprite:FlxSprite;

	override public function new(x:Float, y:Float):Void
	{
		super(x, y);

		frames = AssetHelper.grabAsset('checkboxThingie', SPARROW, 'images/menus/optionsMenu');
		animation.addByPrefix('true', 'Check Box unselected', 24, false);
		animation.addByPrefix('false', 'Check Box selecting animation', 24, false);

		addOffset('true', 0, -30);
		addOffset('false', 25, 55);

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (frames != null && parentSprite != null)
		{
			setPosition(parentSprite.x + parentSprite.width + 10, parentSprite.y - 30);
			scrollFactor.set(parentSprite.scrollFactor.x, parentSprite.scrollFactor.y);
		}
	}
}
class SelectorThingie extends FlxTypedSpriteGroup<FlxSprite>
{
	/**
		in case contributors wanna do it for me because I'm probably not finishing it now
		the idea is to have a alphabet text with the name of your choice, it is always a bold one
		then two arrows pointing left and right, they are also a alphabet text

		the little arrows change color depending on the current pressed direction
		from their normal color, to yellow, then back to their normal color

		e.g: User Interface Style <- FNF ->
	**/
	//
	public var nameSprite:Alphabet;

	public var arrowLeft:Alphabet;
	public var arrowRight:Alphabet;

	public var name(default, null):String;
	public var number(default, null):Bool;
	public var choice(default, set):String;

	public inline function set_choice(myChoice:String):String
	{
		choice = myChoice;
		number = (Std.parseInt(myChoice) != null ? true : false);
		if (choice != null)
			nameSprite.text = myChoice;
		return myChoice;
	}

	public var ops:Array<String> = [];

	override public function new(x:Float, y:Float, name:String, ops:Array<String>):Void
	{
		super(x, y);

		this.name = name;
		this.ops = ops;

		nameSprite = new Alphabet(0, 0, Std.string(choice), true);
		arrowLeft = new Alphabet(0, 0, "<", true);
		arrowRight = new Alphabet(0, 0, ">", true);

		add(nameSprite);
		add(arrowLeft);
		add(arrowRight);

		choice = Std.string(OptionsAPI.getPref(name, false));
	}

	public function changeArrow(rightPress:Bool = false):Void
	{
		var myArrow:Alphabet = (rightPress ? arrowRight : arrowLeft);
		var originalColor:Int = myArrow.color;

		FlxTween.tween(myArrow, {color: 0xFFFFF700}, 0.8, {
			ease: FlxEase.sineOut,
			onComplete: function(tween:FlxTween)
			{
				FlxTween.tween(myArrow, {color: originalColor}, 0.3);
			}
		});
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
