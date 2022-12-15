package funkin.objects.ui.fonts;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

/**
	Loosley based on FlxTypeText lolol
**/
class Alphabet extends FlxTypedSpriteGroup<AlphaCharacter>
{
	// for menu shit
	public var isMenuItem:Bool = false;
	public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var disableX:Bool = false;
	public var targetY:Float = 0;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var xTo = 100;

	public var text:String = "";

	public var isBold:Bool = false;

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;

	var splitWords:Array<String> = [];

	override public function set_color(color:Int):Int
	{
		for (char in group.members)
		{
			if (char is AlphaCharacter) // this *should* address errors hopefully
			{
				//
				var myChar = cast(char, AlphaCharacter);
				myChar.changeColor(color, isBold);
			}
		}

		return super.set_color(color);
	}

	public function new(x:Float = 0, y:Float = 0, text:String = "", isBold:Bool = false):Void
	{
		super(x, y);

		forceX = Math.NEGATIVE_INFINITY;

		this.text = text;
		this.isBold = isBold;

		if (text != null && text != "")
			addText();
	}

	public function addText():Void
	{
		splitWords = text.split("");

		var xPos:Float = 0;
		for (character in splitWords)
		{
			if (character == " " || character == "-")
				lastWasSpace = true;

			if (AlphaCharacter.alphabet.indexOf(character.toLowerCase()) != -1)
			{
				if (lastSprite != null)
					xPos = lastSprite.x + lastSprite.width;

				if (lastWasSpace)
				{
					xPos += 40;
					lastWasSpace = false;
				}

				var type:LetterType = (isBold ? BOLD : LETTER);

				var letter:AlphaCharacter = new AlphaCharacter(xPos, 0);

				letter.createChar(character, type);
				letter.changeColor(color, type == BOLD);
				add(letter);

				lastSprite = letter;
			}
		}
	}

	override function update(elapsed:Float):Void
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48), 0.16);

			if (forceX != Math.NEGATIVE_INFINITY)
				x = forceX;
			else if (disableX)
				x = FlxMath.lerp(x, xTo, elapsed * 6);
			else
				x = FlxMath.lerp(x, (targetY * 20) + 90, 0.16);
		}

		super.update(elapsed);
	}
}

enum LetterType
{
	LETTER;
	BOLD;
	NUMBER;
	SYMBOL;
}

class AlphaCharacter extends FlxSprite
{
	public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";
	public static var symbols:String = "\\/|~#$%()*+-:;<=>@[]^_.,'!?";
	public static var numbers:String = "1234567890";

	public var row:Int = 0;

	public function new(x:Float, y:Float):Void
	{
		super(x, y);

		frames = AssetHandler.grabAsset('alphabet', SPARROW, "images/ui/base");
		antialiasing = true;
	}

	public function changeColor(c:FlxColor, bold:Bool):Void
	{
		if (bold)
		{
			colorTransform.redMultiplier = c.redFloat;
			colorTransform.greenMultiplier = c.greenFloat;
			colorTransform.blueMultiplier = c.blueFloat;
		}
		else
		{
			colorTransform.redOffset = c.red;
			colorTransform.greenOffset = c.green;
			colorTransform.blueOffset = c.blue;
		}
	}

	/**
		Combined all functions into one
	**/
	public function createChar(letter:String, type:LetterType):Void
	{
		// TODO: make this easier maybe

		var letterCase:String = "";

		switch (type)
		{
			case LETTER:
				if (letter.toUpperCase() != letter)
					letterCase = " lowercase";
				else
					letterCase = " capital";
			case BOLD:
				letterCase = " bold";
			default:
				letterCase = "";
		}

		switch (letter)
		{
			case '#':
				animation.addByPrefix(letter, 'hashtag', 24);
			case '$':
				animation.addByPrefix(letter, 'dollarsign', 24);
			case '|':
				animation.addByPrefix(letter, 'pipe', 24);
			case '~':
				animation.addByPrefix(letter, 'tilde', 24);
			case '<':
				animation.addByPrefix(letter, 'lessThan', 24);
			case '>':
				animation.addByPrefix(letter, 'greaterThan', 24);
			case '=':
				animation.addByPrefix(letter, 'equal', 24);
			case '\\':
				animation.addByPrefix(letter, 'backslash', 24);
			case '@':
				animation.addByPrefix(letter, 'atSign', 24);
			case '.':
				animation.addByPrefix(letter, 'period', 24);
				y += 50;
			case "'":
				animation.addByPrefix(letter, 'apostraphie', 24);
			case "?":
				animation.addByPrefix(letter, 'question mark', 24);
			case "!":
				animation.addByPrefix(letter, 'exclamation point', 24);
			default:
				animation.addByPrefix(letter, (type == BOLD ? letter.toUpperCase() : letter) + letterCase, 24);
		}

		animation.play(letter);
		updateHitbox();

		if (type == LETTER)
		{
			FlxG.log.add('the row' + row);

			y = (110 - height);
			y += row * 60;
		}
	}
}
