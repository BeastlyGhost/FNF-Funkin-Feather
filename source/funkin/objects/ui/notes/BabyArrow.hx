package funkin.objects.ui.notes;

/**
	`BabyArrow`s are sprites that are attached to your `Strum`line,
	this class simply initializes said `BabyArrow`s
**/
class BabyArrow extends FeatherSprite
{
	public var swagWidth:Float = 160 * 0.7;

	public static var actions:Array<String> = ['left', 'down', 'up', 'right'];
	public static var colors:Array<String> = ['purple', 'blue', 'green', 'red'];

	/**
		for Feather Notesplashes
		will eventually be used for the notes themselves
	**/
	public static var colorPresets:Map<String, Array<Int>> = [
		"default" => [0xFFC24C9A, 0xFF03FFFF, 0xFF12FA05, 0xFFF9393F],
		"pixel" => [0xFFE276FF, 0xFF3DCAFF, 0xFF71E300, 0xFFFF884E],
	];

	public var index:Int = 0;

	public var defaultAlpha:Float = 0.8;

	public function new(index:Int):Void
	{
		super(x, y);

		alpha = defaultAlpha;

		this.index = index;

		updateHitbox();
		scrollFactor.set();
	}

	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		super.playAnim(AnimName);

		centerOffsets();
		centerOrigin();
	}
}
