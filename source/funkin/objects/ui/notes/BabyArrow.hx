package funkin.objects.ui.notes;

/**
	`BabyArrow`s are sprites that are attached to your `Strumline`line,
	this class simply initializes said `BabyArrow`s
**/
class BabyArrow extends FeatherSprite
{
	public static final swagWidth:Float = 160 * 0.7;

	public static final actions:Array<String> = ['left', 'down', 'up', 'right'];
	public static final colors:Array<String> = ['purple', 'blue', 'green', 'red'];

	public var index:Int = 0;

	public var defaultAlpha:Float = 0.8;

	public function new(index:Int)
	{
		super(x, y);

		alpha = defaultAlpha;

		this.index = index;

		updateHitbox();
		scrollFactor.set();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		super.playAnim(AnimName);

		centerOffsets();
		centerOrigin();
	}
}
