package funkin.objects.ui;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.essentials.song.Conductor;
import sys.FileSystem;

/**
	the Icon class handles the little icons that appear bouncing on the User Interface,
	they often show up following the Health Bar
**/
class Icon extends FlxSprite {
	public var parentSprite:FlxSprite;
	public var initialWidth:Float = 0;
	public var initialHeight:Float = 0;

	public var shouldBop:Bool = true;

	public var char:String = 'placeholder';
	public var suffix:String = '';

	public function new(char:String = 'placeholder', flip:Bool = false):Void {
		super();

		this.char = char;
		setIcon(char, flip);
	}

	var bopTween:FlxTween;

	public function doBops(time:Float):Void {
		if (!shouldBop)
			return;

		scale.set(1.2, 1.2);
		if (bopTween != null)
			bopTween.cancel();
		bopTween = FlxTween.tween(this.scale, {x: 1, y: 1}, time / Conductor.songRate, {ease: FlxEase.expoOut});
	}

	public dynamic function updateFrame(health:Float):Void {
		if (graphic != null) {
			animation.curAnim.curFrame = 0;

			if (frames != null) {
				if (health < 20)
					animation.curAnim.curFrame = 1;
			}
		}
	}

	public function setIcon(char:String = 'placeholder', beFlipped:Bool = false):Void {
		var stringTrim:String = char;
		if (stringTrim.contains('-'))
			stringTrim = stringTrim.substring(0, stringTrim.indexOf('-'));

		if (!FileSystem.exists(AssetHelper.grabAsset('icon-$char$suffix', IMAGE, 'data/characters/$char'))) {
			if (char != stringTrim)
				char = stringTrim;
			else
				char = 'placeholder';
		}

		var iconAsset:FlxGraphic = AssetHelper.grabAsset('icon-$char$suffix', IMAGE, 'data/characters/$char');

		if (iconAsset == null)
			return;

		loadGraphic(iconAsset); // get file size

		// icons with endless frames;
		var iconWidth:Int = Std.int(iconAsset.width / 150) - 1;
		iconWidth = iconWidth + 1;

		loadGraphic(iconAsset, true, Std.int(iconAsset.width / iconWidth), iconAsset.height); // then load it

		initialWidth = width;
		initialHeight = height;
		antialiasing = true;

		animation.add('icon', [for (i in 0...frames.frames.length) i], 0, false, beFlipped);
		animation.play('icon');
		scrollFactor.set();
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (frames != null && parentSprite != null) {
			setPosition(parentSprite.x + parentSprite.width + 10, parentSprite.y - 30);
			scrollFactor.set(parentSprite.scrollFactor.x, parentSprite.scrollFactor.y);
		}
	}
}
