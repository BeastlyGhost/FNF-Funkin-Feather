package funkin.objects.ui.notes;

import flixel.FlxG;

class NoteSplash extends FeatherSprite
{
	public var index:Int;

	public function new(x:Float, y:Float, index:Int = 0):Void
	{
		super(x, y);

		this.index = index;
		ID = index;

		frames = AssetHandler.grabAsset("noteSplashes", SPARROW, "data/notes/default/base");

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

	public function setupNoteSplash(x:Float, y:Float, index:Int = 0):Void
	{
		this.index = index;
		ID = index;

		setPosition(x, y);
		animation.play('note' + index + '-' + FlxG.random.int(0, 1), true);
		updateHitbox();
		offset.set(60, 30);
	}

	override public function update(elapsed:Float):Void
	{
		if (animation.curAnim.finished)
			kill();

		super.update(elapsed);
	}
}
