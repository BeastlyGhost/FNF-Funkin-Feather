package funkin.objects.ui.fonts;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import funkin.objects.ui.fonts.AlphaLetters;

enum AlphaDisplay {
	BASE;
	LIST;
}

/**
	Loosley based on FlxTypeText lolol
**/
class Alphabet extends FlxTypedSpriteGroup<LetterSprite> {
	public var text(default, set):String;
	public var words:Array<String> = [];

	public function set_text(tempText:String):String {
		tempText = tempText.replace('\\n', '\n');
		this.text = tempText;
		return tempText;
	}

	public var isBold:Bool = false;

	// for menu shit
	public var displayStyle:AlphaDisplay = BASE;
	public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var disableX:Bool = false;
	public var displacement:FlxPoint;
	public var targetY:Float = 0;

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:LetterSprite;
	var xPosResetted:Bool = false;
	var sectionSpaces:Int = 0;

	public override function set_color(color:Int):Int {
		for (char in group.members) {
			if (char is LetterSprite) // this *should* address errors hopefully
			{
				//
				var myChar = cast(char, LetterSprite);
				myChar.changeColor(color, isBold);
			}
		}

		return super.set_color(color);
	}

	public function new(x:Float = 0, y:Float = 0, text:String = "", isBold:Bool = false):Void {
		super(x, y);

		displacement = new FlxPoint(0, 0);

		forceX = Math.NEGATIVE_INFINITY;

		this.text = text;
		this.isBold = isBold;

		if (text != null && text != "")
			addText();
	}

	public function addText():Void {
		words = text.split("");

		var xPos:Float = 0;
		for (character in words) {
			var isSpace:Bool = (character == " " || character == "_");
			if (isSpace)
				sectionSpaces++;

			var indexLetter:Bool = LetterSprite.getIndex(character, LETTER) != -1;
			var indexSymbol:Bool = LetterSprite.getIndex(character, SYMBOL) != -1;
			var indexNumber:Bool = LetterSprite.getIndex(character, NUMBER) != -1;

			if ((indexLetter || indexSymbol || indexNumber) && (!isBold || !isSpace)) {
				if (lastSprite != null)
					xPos = lastSprite.x + lastSprite.width;

				if (sectionSpaces > 0)
					xPos += 40 * sectionSpaces;
				sectionSpaces = 0;

				var letter:LetterSprite = new LetterSprite(xPos, 0);
				var type:LetterType = LETTER;

				if (indexNumber)
					type = NUMBER;
				else if (indexSymbol)
					type = SYMBOL;
				else
					type = LETTER;

				letter.createChar(character, type, isBold);
				add(letter);

				lastSprite = letter;
			}
		}
	}

	override function update(elapsed:Float):Void {
		switch (displayStyle) {
			case LIST:
				var scaledY:Float = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
				var toX:Float = (FlxMath.lerp(x, (targetY * 20) + 90, 0.16));

				y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48), 0.16);

				if (disableX)
					toX = FlxMath.lerp(x, displacement.x, elapsed * 6);
				else if (forceX != Math.NEGATIVE_INFINITY)
					toX = forceX;

				x = toX;
			default:
		}

		super.update(elapsed);
	}
}

/**
	---- TODO ----
	Letter Offsets
	Latin Support (maybe, just maybe)
**/
class LetterSprite extends PlumaSprite {
	public var offsetIncrement:FlxPoint = new FlxPoint(0, 0);
	public var texture(default, set):String = 'default/alphabet';
	public var defaultFramerate:Int = 24;

	public static function getIndex(char:String, type:LetterType):Int {
		var index:String = AlphaLetters.letterList.get(type);
		return index.indexOf(char.toLowerCase());
	}

	public function set_texture(tex:String):String {
		// safety check
		var pastAnim:String = null;

		if (animation != null)
			pastAnim = animation.name;

		texture = tex;
		frames = AssetHelper.grabAsset(tex, SPARROW, "images/ui");

		// set the framerate
		defaultFramerate = 24;

		if (pastAnim != null) {
			animation.addByPrefix(pastAnim, pastAnim, defaultFramerate);
			animation.play(pastAnim, true);
			updateHitbox();
		}
		return tex;
	}

	public var row:Int = 0;

	public function new(x:Float, y:Float):Void {
		super(x + offsetIncrement.x, y + offsetIncrement.y);

		texture = 'default/alphabet';
	}

	public function changeColor(c:FlxColor, bold:Bool):Void {
		if (texture == null)
			return;

		if (bold) {
			colorTransform.redMultiplier = c.redFloat;
			colorTransform.greenMultiplier = c.greenFloat;
			colorTransform.blueMultiplier = c.blueFloat;
		} else {
			colorTransform.redOffset = c.red;
			colorTransform.greenOffset = c.green;
			colorTransform.blueOffset = c.blue;
		}
	}

	/**
		Combined all functions into one
	**/
	public function createChar(letter:String, type:LetterType, isBold:Bool = false):Void {
		if (texture == null)
			return;

		var letterCase:String = null;

		if (letterCase == null) {
			switch (type) {
				case LETTER:
					if (isBold) {
						if (letter.toUpperCase() != letter)
							letterCase = " lower bold";
						else
							letterCase = " upper bold";
					} else
						letterCase = " normal";
				default:
					if (isBold)
						letterCase = " bold";
					else
						letterCase = " normal";
			}
		}

		/**
			I have no names for these
			https://cdn.discordapp.com/attachments/1000603105265733749/1051670973029564426/FjsH6O6WIAEPclK.jpg
		**/

		for (lettah => thingies in AlphaLetters.letterMap) {
			if (lettah != null && thingies != null) {
				if (thingies.anim != null)
					animation.addByPrefix(lettah, thingies.anim + letterCase, defaultFramerate);
				// trace('added: ${thingies.anim} to Alphabet');

				var chosenAdjustArray:Array<Float> = (isBold ? thingies.boldOffset : thingies.offset);
				if (chosenAdjustArray != null)
					offsetIncrement.set(chosenAdjustArray[0], chosenAdjustArray[1]);
			}
		}

		animation.addByPrefix(letter, letter.toUpperCase() + letterCase, defaultFramerate);
		animation.play(letter);
		updateHitbox();

		/**
				// so uhh this is basically useless now and causes more problems than solves them??
				// it's only really useful for old alphabet
				// leaving it here just in case yk
				// @BeastlyGhost

				if (type == LETTER)
			{
					// FlxG.log.add('the row' + row);

					y = (110 - height);
					y += row * 60;
				}
		**/
	}
}
