package funkin.objects.ui.fonts;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import funkin.objects.ui.fonts.AlphaLetters;

/**
	Loosley based on FlxTypeText lolol
**/
class Alphabet extends FlxTypedSpriteGroup<LetterSprite>
{
	public var text(default, set):String;
	public var words:Array<String> = [];

	public function set_text(tempText:String):String
	{
		tempText = tempText.replace('\\n', '\n');
		this.text = tempText;
		return tempText;
	}

	public var isBold:Bool = false;

	// for menu shit
	public var isMenuItem:Bool = false;
	public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var disableX:Bool = false;
	public var displacement:FlxPoint;
	public var targetY:Float = 0;

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:LetterSprite;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;

	override public function set_color(color:Int):Int
	{
		for (char in group.members)
		{
			if (char is LetterSprite) // this *should* address errors hopefully
			{
				//
				var myChar = cast(char, LetterSprite);
				myChar.changeColor(color, isBold);
			}
		}

		return super.set_color(color);
	}

	public function new(x:Float = 0, y:Float = 0, text:String = "", isBold:Bool = false):Void
	{
		super(x, y);

		displacement = new FlxPoint(0, 0);

		forceX = Math.NEGATIVE_INFINITY;

		this.text = text;
		this.isBold = isBold;

		if (text != null && text != "")
			addText();
	}

	public function addText():Void
	{
		words = text.split("");

		var xPos:Float = 0;
		for (character in words)
		{
			if (character == " " || character == "-")
				lastWasSpace = true;

			if (LetterSprite.alphabet.indexOf(character.toLowerCase()) != -1)
			{
				if (lastSprite != null)
					xPos = lastSprite.x + lastSprite.width;

				if (lastWasSpace)
				{
					xPos += 40;
					lastWasSpace = false;
				}

				var type:LetterType = (isBold ? BOLD : LETTER);
				var letter:LetterSprite = new LetterSprite(xPos, 0);

				letter.createChar(character, type);
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
				x = FlxMath.lerp(x, displacement.x, elapsed * 6);
			else
				x = FlxMath.lerp(x, (targetY * 20) + 90, 0.16);
		}

		super.update(elapsed);
	}
}

/**
	---- TODO ----
	Letter Offsets
	Symbol Support
	Latin Support
**/
class LetterSprite extends FlxSprite
{
	public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";
	public static var symbols:String = "\\/|~#$%()*+-:;<=>@[]^_.,'!?";
	public static var numbers:String = "1234567890";

	public var offsetIncrement:FlxPoint;
	public var texture(default, set):String = 'base/alphabet';
	public var defaultFramerate:Int = 24;

	public function set_texture(tex:String):String
	{
		// safety check
		var pastAnim:String = null;

		if (animation != null)
			pastAnim = animation.name;

		texture = tex;
		frames = AssetHandler.grabAsset(tex, SPARROW, "images/ui");

		// set the framerate
		defaultFramerate = 24;

		if (pastAnim != null)
		{
			animation.addByPrefix(pastAnim, pastAnim, defaultFramerate);
			animation.play(pastAnim, true);
			updateHitbox();
		}
		return tex;
	}

	public var row:Int = 0;

	public function new(x:Float, y:Float):Void
	{
		super(x, y);

		texture = 'base/alphabet';

		offsetIncrement = new FlxPoint(0, 0);

		x += offsetIncrement.x;
		y += offsetIncrement.y;
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

		/**
			I have no names for these
			https://cdn.discordapp.com/attachments/1000603105265733749/1051670973029564426/FjsH6O6WIAEPclK.jpg
		**/

		for (lettah => thingies in AlphaLetters.letterMap)
		{
			if (lettah != null && thingies != null)
			{
				if (thingies.anim != null)
					animation.addByPrefix(letter, thingies.anim, defaultFramerate);
				// trace('added: ${thingies.anim} to Alphabet');

				var chosenAdjustArray:Array<Float> = (type == BOLD ? thingies.boldOffset : thingies.normalOffset);

				if (chosenAdjustArray != null)
					offsetIncrement.set(chosenAdjustArray[0], chosenAdjustArray[1]);
			}
		}

		animation.addByPrefix(letter, (type == BOLD ? letter.toUpperCase() : letter) + letterCase, defaultFramerate);
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
