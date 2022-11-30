package states.menus;

import base.data.OptionsMeta;
import base.song.MusicState;

/**
	the Options Menu, used for managing game options
**/
class OptionsMenu extends MusicBeatState
{
	var categories:Map<String, Array<OptionData>> = [
		"main" => [
			{name: "preferences", type: DYNAMIC, description: "Define your Game Preferences."},
			{name: "keybinds", type: DYNAMIC, description: "Define your preferred keys for use during Gameplay."}
		],
	];

	override function create()
	{
		super.create();

		// force switch lol this is unfinished anyways
		MusicState.switchState(new MainMenu());
	}
}
