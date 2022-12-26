package fnf.states.substates;

import feather.BaseMenu.BaseSubMenu;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import fnf.helpers.PlayerInfo;
import fnf.objects.ui.Alphabet;
import fnf.song.Conductor;
import fnf.song.MusicState;
import fnf.states.PlayState;
import sys.thread.Mutex;
import sys.thread.Thread;

/**
	a Subclass for when you pause on `PlayState`
	initializes simple options with simple functions
**/
class PauseSubstate extends BaseSubMenu {
	var listMap:Map<String, Array<String>> = [
		"default" => [
			"Resume Song",
			"Restart Song",
			"Change Keybinds",
			"Exit to Options",
			"Exit to menu"
		],
		"charting" => ["Exit to Charter", "Leave Charting Mode", "Change Keybinds", "Exit to menu"],
		"no-resume" => ["Restart Song", "Change Keybinds", "Exit to Options", "Exit to menu"],
	];

	var pauseMusic:FlxSound;
	var mutex:Mutex;

	public function new(x:Float, y:Float, listName:String = "default"):Void {
		super();

		wrappableGroup = listMap.get(listName);

		mutex = new Mutex();
		Thread.create(function() {
			mutex.acquire();
			pauseMusic = new FlxSound().loadEmbedded(AssetHelper.grabAsset('breakfast', SOUND, "music"), true, true);
			pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
			FlxG.sound.list.add(pauseMusic);
			pauseMusic.volume = 0;
			mutex.release();
		});

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var stringDiff = FeatherUtils.getDifficulty(PlayState.difficulty);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text = PlumaStrings.toTitle(PlayState.song.name) + ' [${stringDiff.replace('-', '').toUpperCase()}]';
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(AssetHelper.grabAsset("vcr", FONT, "data/fonts"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDeaths:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDeaths.text = 'Blue balled: ' + PlayerInfo.stats.deaths;
		levelDeaths.scrollFactor.set();
		levelDeaths.setFormat(AssetHelper.grabAsset("vcr", FONT, "data/fonts"), 32);
		levelDeaths.updateHitbox();
		add(levelDeaths);

		levelInfo.alpha = 0;
		levelDeaths.alpha = 0;
		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDeaths.x = FlxG.width - (levelDeaths.width + 20);

		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDeaths, {alpha: 1, y: levelDeaths.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.6});
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

		itemContainer = new FlxTypedGroup<Alphabet>();
		add(itemContainer);

		for (i in 0...wrappableGroup.length) {
			var base:Alphabet = new Alphabet(0, (70 * i) + 30, wrappableGroup[i], false);
			base.displayStyle = LIST;
			base.targetY = i;
			itemContainer.add(base);
		}

		updateSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		updateSelection(Controls.isJustPressed("up") ? -1 : Controls.isJustPressed("down") ? 1 : 0);

		if (Controls.isJustPressed("accept")) {
			var mySelection = wrappableGroup[Math.floor(selection)].toLowerCase();

			switch (mySelection) {
				case "resume song":
					close();
				case "restart song":
					MusicState.resetState();
					Conductor.stopSong();
				case "exit to options":
					MusicState.switchState(new fnf.states.menus.OptionsMenu(true));
					Conductor.stopSong();
				case "exit to charter":
					MusicState.switchState(new fnf.states.editors.ChartEditor());
					Conductor.stopSong();
				case "leave charting mode":
					PlayState.gameplayMode = FREEPLAY;
					MusicState.resetState();
				case "change keybinds":
					openSubState(new KeybindsSubstate(false));
				case "exit to menu":
					PlayerInfo.stats.deaths = 0;
					Conductor.stopSong();

					if (PlayState.gameplayMode == STORY)
						MusicState.switchState(new fnf.states.menus.MainMenu());
					else
						MusicState.switchState(new fnf.states.menus.FreeplayMenu());
			}
		}

		if (pauseMusic != null && pauseMusic.playing) {
			if (pauseMusic.volume < 0.5)
				pauseMusic.volume += 0.01 * elapsed;
		}
	}

	public override function updateSelection(newSelection:Int = 0):Void {
		super.updateSelection(newSelection);

		if (newSelection != 0)
			FSound.playSound("scrollMenu", 'sounds/menus');
	}

	override function destroy():Void {
		if (pauseMusic != null)
			pauseMusic.destroy();
		super.destroy();
	}
}
