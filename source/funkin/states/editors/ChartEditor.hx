package funkin.states.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import funkin.objects.ui.Icon;
import funkin.objects.ui.notes.Note;
import funkin.song.Conductor;
import funkin.song.MusicState;
import funkin.song.SongFormat.FeatherSong;
import haxe.Json;
import openfl.net.FileReference;

enum CharterTheme
{
	FLIXEL_WHITE; // default because i'm uncreative asf
	PSYCH_WHITE; // from public concepts: https://twitter.com/Shadow_Mario_/status/1442549049777922048
	HOPELESS_DARK; // AMOLED, will be inspired by Alice: Mad & Hopeless
	FOREVER_DARK; // Forever Engine Chart Editor Style
	IZZY_DARK; // Izzy Engine Chart Editor Style
}

/**
	TODO:

	-- Grid Style
		Grid will always be at the center of the screen
		grid shouldn't move like the base one, but rather,
		the white strumline should move down, so the grid is always at a fixed position

	-- UI Box
		UI Box should act just like it did on the base game
		with a few additional bits here and there to make it
		look fresh and new

	both the grid and UI Boxes will be customizable depending on your set UI Style

	-- UI Box Sections

		- SONG
		- SECTION
		- NOTES
		- EVENTS

	-- Section Contents

		[SONG]
		- Song Name Box
		- Song BPM Changer
		- Song Scroll Speed Changer
		- Song Player, Opponent and Crowd Changer
		- Save Chart and Chart Events Buttons
		- Mute Instrumental Checkbox
		- Mute Vocals Checkbox

		[SECTION]
		- Copy Notes Button
		- Paste Notes Button
		- Clear Notes from Section Button
		- Clear Notes from *every* Section Button
		- Swap Notes from Section A to Section B
		- Drop Down for pointing where the camera should be on gameplay ["Player", "Opponent", "Crowd"]
		- Section BPM (for BPM Changes)
		- Section Attributes Substate (toggles Alt Animation Sections and GF Sections)

		[NOTES]
		- a Stepper for setting a note's Hold Length
		- a Note Type Drop Down
		- a Note "Animation" Box for setting Custom Animations for notes

		[EVENTS]
		- a Event List Drop Down
		- Event Stacker Buttons
		- Event Value Boxes
		- Event Line Color Steppers / Sliders
	--
**/
/**
	a Chart Editor for you to edit your song charts and export them freely!
**/
class ChartEditor extends MusicBeatState
{
	var defaultUIStyle:CharterTheme = FLIXEL_WHITE; // fallback in case the theme fails to load

	var uiStyle:CharterTheme = FLIXEL_WHITE;
	var boxUI:FlxUITabMenu;

	var song:FeatherSong;

	var gridMain:FlxSprite;
	var gridSize:Int = 45;

	var mouseHighlight:FlxSprite;
	var infoText:FlxText;

	var iconP1:Icon;
	var iconP2:Icon;

	var renderedNotes:FlxTypedGroup<Note>;
	var renderedHolds:FlxTypedGroup<Note>;
	var renderedLabels:FlxTypedGroup<FlxText>;

	var noteSelection:Int;

	override function create()
	{
		super.create();

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.mouse.visible = true;

		generateEditorGrid();

		/*
			iconP1 = new Icon('bf');
			iconP2 = new Icon('bf');
			iconP1.scrollFactor.set(1, 1);
			iconP2.scrollFactor.set(1, 1);

			iconP1.setGraphicSize(0, 45);
			iconP2.setGraphicSize(0, 45);

			add(iconP1);
			add(iconP2);

			iconP1.setPosition(0, -100);
			iconP2.setPosition(gridMain.width / 2, -100);
		 */

		renderedNotes = new FlxTypedGroup<Note>();
		renderedHolds = new FlxTypedGroup<Note>();

		song = PlayState.song;
		// loadSong(song.name);
		// Conductor.changeBPM(song.bpm);
		// Conductor.mapBPMChanges(song);

		infoText = new FlxText(0, FlxG.height, 0, "SONG: " + song.name, 16);
		infoText.scrollFactor.set();
		add(infoText);

		mouseHighlight = new FlxSprite().makeGraphic(gridSize, gridSize);
		mouseHighlight.screenCenter(XY);
		add(mouseHighlight);

		var tabs = [
			{name: "Song", label: 'Song Data'},
			{name: "Section", label: 'Section Data'},
			{name: "Note", label: 'Note Data'}
		];

		boxUI = new FlxUITabMenu(null, tabs, true);

		boxUI.resize(300, 400);
		boxUI.x = FlxG.width / 1;
		boxUI.y = 20;
		add(boxUI);

		addSongUI();

		mousePosUpdate();
	}

	function addSongUI()
	{
		var tab_group_song = new FlxUI(null, boxUI);
		tab_group_song.name = "Song";

		var songName = new FlxUIInputText(10, 10, 70, song.name, 8);

		tab_group_song.add(new FlxText(songName.x, songName.y - 15, 0, "Song Name:"));
		tab_group_song.add(songName);

		boxUI.addGroup(tab_group_song);
		boxUI.scrollFactor.set();
	}

	function generateEditorGrid()
	{
		gridMain = FlxGridOverlay.create(gridSize, gridSize, gridSize * 8, gridSize * 16);
		gridMain.screenCenter(XY);
		add(gridMain);

		var gridBlackLine:FlxSprite = new FlxSprite(gridMain.x + gridMain.width / 2).makeGraphic(2, Std.int(gridMain.height), 0xFF000000);
		add(gridBlackLine);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		mousePosUpdate();

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(renderedNotes))
			{
				renderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						removeNote(note);
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridMain.x
					&& FlxG.mouse.x < (gridMain.x + gridMain.width)
					&& FlxG.mouse.y > 0
					&& FlxG.mouse.y < getYfromStrum(FlxG.sound.music.length))
				{
					placeNote();
				}
			}
		}

		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)
		{
			var _file:FileReference;
			var json = {
				"song": song
			};

			var data:String = Json.stringify(json, '\t');

			if ((data != null) && (data.length > 0))
			{
				_file = new FileReference();
				_file.save(data.trim(), song.name.toLowerCase() + ".json");
			}
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			PlayState.songName = song.name;
			PlayState.gameplayMode = CHARTING;
			PlayState.difficulty = 1;

			MusicState.switchState(new PlayState());
		}
	}

	function updateGrid():Void
	{
		renderedNotes.clear();
		renderedHolds.clear();

		/*
			if (song.sectionNotes[curSection].bpm > 0)
			{
				Conductor.changeBPM(song.sectionNotes[curSection].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			else
			{
				var daBPM:Float = song.bpm;
				for (i in 0...curSection)
					if (song.sectionNotes[i].bpm > 0)
						daBPM = song.sectionNotes[i].bpm;
				Conductor.changeBPM(daBPM);
			}
		 */

		for (i in song.sectionNotes)
		{
			var index:Int = i.index;
			var time:Float = i.time;
			var type:String = i.type;
			var holdLength:Float = i.holdLength;

			var note:Note = new Note(time, index, type, null, false);
			note.sustainLength = holdLength;
			note.setGraphicSize(gridSize, gridSize);
			note.updateHitbox();
			note.screenCenter(X);

			if (song.sectionNotes != null && song.sectionNotes[curSection] != null)
			{
				var isMustPress:Bool = song.sectionNotes[curSection].cameraPoint == "player";

				note.x -= ((gridSize * 6) - (gridSize / 2));
				note.x += Math.floor((isMustPress ? (index + 4) % 8 : index) * gridSize);

				note.y = Math.floor(getYfromStrum(time));

				renderedNotes.add(note);
				trace("Added Note at " + Math.floor(getYfromStrum(time)));
			}
		}
	}

	function placeNote()
	{
		var time:Float = getStrumTime(mouseHighlight.y) + getSectionStart();
		var index:Int = Math.floor(FlxG.mouse.x / gridSize);
		var length:Float = 0;

		// noteSelection = song.sectionNotes[curSection].index;

		updateGrid();
	}

	function removeNote(note:Note)
	{
		var index:Null<Int> = note.index;
		var isMustPress:Bool = song.sectionNotes[curSection].cameraPoint == "player";

		if (index > -1 && note.mustPress != isMustPress)
			index += 4;

		if (index > -1)
		{
			for (i in song.sectionNotes)
			{
				if (i.time == note.step && i.index == note.index)
				{
					song.sectionNotes.remove(i);
					break;
				}
			}
		}

		updateGrid();
	}

	function mousePosUpdate()
	{
		if (FlxG.mouse.x > gridMain.x
			&& FlxG.mouse.x < (gridMain.x + gridMain.width)
			&& FlxG.mouse.y > 0
			&& FlxG.mouse.y < getYfromStrum(FlxG.sound.music.length))
		{
			mouseHighlight.x = (Math.floor((FlxG.mouse.x - gridMain.x) / gridSize) * gridSize) + gridMain.x;
			if (FlxG.keys.pressed.SHIFT)
				mouseHighlight.y = FlxG.mouse.y;
			else
				mouseHighlight.y = Math.floor(FlxG.mouse.y / gridSize) * gridSize;
		}
	}

	function getStrumTime(yPos:Float):Float
		return FlxMath.remapToRange(yPos, gridMain.y, gridMain.y + gridMain.height, 0, 16 * Conductor.stepCrochet);

	function getYfromStrum(strumTime:Float):Float
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridMain.y, gridMain.y + gridMain.height);

	function getSectionStart():Float
	{
		var daBPM:Float = song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			if (song.sectionNotes[i].bpm > 0)
				daBPM = song.sectionNotes[i].bpm;
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}
}
