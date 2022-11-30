package funkin.objects.ui.notes;

import flixel.FlxG;

class NoteSplash extends FeatherSprite
{
	public function new(x:Float, y:Float, index:Int = 0)
	{
		super(x, y);

		frames = AssetHandler.grabAsset("noteSplashes", SPARROW, "images/ui/default");

		animation.addByPrefix('note1-0', 'note impact 1 blue', 24, false);
		animation.addByPrefix('note2-0', 'note impact 1 green', 24, false);
		animation.addByPrefix('note0-0', 'note impact 1 purple', 24, false);
		animation.addByPrefix('note3-0', 'note impact 1 red', 24, false);
		animation.addByPrefix('note1-1', 'note impact 2 blue', 24, false);
		animation.addByPrefix('note2-1', 'note impact 2 green', 24, false);
		animation.addByPrefix('note0-1', 'note impact 2 purple', 24, false);
		animation.addByPrefix('note3-1', 'note impact 2 red', 24, false);

		setupNoteSplash(x, y, index);
	}

	public function setupNoteSplash(x:Float, y:Float, ?index:Int = 0)
	{
		setPosition(x, y);
		animation.play('note' + index + '-' + FlxG.random.int(0, 1), true);
		animation.curAnim.frameRate += FlxG.random.int(-2, 2);
		updateHitbox();
		offset.set(60, 30);
	}

	override public function update(elapsed:Float)
	{
		if (animation.curAnim.finished)
			kill();

		super.update(elapsed);
	}
}
