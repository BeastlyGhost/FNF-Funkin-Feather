package feather.options;

// Stores Every Class with Option Names
// used in the Options Menu

class Preferences extends BaseList {
	public override function new():Void {
		super([
			'Downscroll',
			'Auto Pause',
			'Skip Splash Screen',
			'Ghost Tapping',
			'Center Notes',
			'Hide Opponent Notes',
			'Safe Frames'
		]);
	}
}

class Miscellaneous extends BaseList {
	public override function new():Void {
		super(['Show FPS', 'Show RAM', 'Show Debug', 'Accurate FPS', 'Framerate Cap']);
	}
}

class Visuals extends BaseList {
	public override function new():Void {
		super([
			'Anti Aliasing',
			'Flashing Lights',
			'Score Bopping',
			'Holds behind Receptors',
			'Show Info Card',
			// 'Quant Style',
			'UI Style',
			'Splash Opacity',
			'Reduce Motion'
		]);
	}
}
