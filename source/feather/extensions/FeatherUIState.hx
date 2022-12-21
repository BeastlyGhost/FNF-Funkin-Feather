package feather.extensions;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.tweens.FlxEase;
import funkin.backend.Transition;

/**
	Global Transition for EVERY State
	@since INFDEV
**/
class FeatherUIState extends FlxUIState
{
	public var defaultTransition:TransType = Slide_UpDown;

	public override function create():Void
	{
		// play the transition if we are allowed to
		if (!FlxTransitionableState.skipNextTransOut)
			Transition.start(0.3, false, defaultTransition, FlxEase.linear);
	}
}
