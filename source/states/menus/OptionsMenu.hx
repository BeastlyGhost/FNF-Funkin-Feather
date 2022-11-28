package states.menus;

import base.data.OptionsMeta;
import base.song.MusicState;

class OptionsMenu extends MusicBeatState
{
	var categories:Map<String, Array<CategoryMetadata>> = [
		"main" => [
			{name: "preferences", type: "subgroup", description: "Define your Game Preferences."},
			{name: "keybinds", type: "keybinds", description: "Define your preferred keys for use during Gameplay."}
		],
	];

	override function create()
	{
		super.create();

		// force switch lol this is unfinished anyways
		MusicState.switchState(new MainMenu());
	}
}
