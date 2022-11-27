package states;

import base.song.*;
import base.song.MusicState.MusicBeatState;
import base.song.SongFormat.CyndaSong;
import base.song.SongFormat.SwagSong;
import base.utils.*;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import haxe.Json;
import objects.Character;
import objects.Stage;
import objects.ui.*;
import objects.ui.Strum.BabyArrow;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;

enum GameModes
{
	STORY;
	FREEPLAY;
	CHARTING;
}

class PlayState extends MusicBeatState
{
	// Song
	public static var song:CyndaSong;

	// User Interface
	public static var strumsGroup:FlxTypedGroup<Strum>;

	public static var storedNotes:FlxTypedGroup<Note>;
	public static var spawnedNotes:Array<Note>;

	public static var gameUI:UI;

	public var strumPlayer:Strum;
	public var strumOpponent:Strum;

	// Characters
	public var player:Character;
	public var spectator:Character;
	public var opponent:Character;

	public var gameStage:Stage;

	// Camera
	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;

	private var camFollow:FlxObject;

	public static var cameraSpeed:Float = 1;
	public static var cameraZoom:Float = 1.05;
	public static var bumpSpeed:Float = 4;

	// Gameplay and Events
	public static var gameplayMode:GameModes;

	public static var canPause:Bool = true;

	public var downscroll:Bool = false;

	public static function generateSong(?name:String):Void
	{
		if (name == null)
			name = 'bopeebo';

		// clear notes prior to storing new ones
		if (storedNotes != null)
			storedNotes.destroy();
		spawnedNotes = [];

		song = ChartParser.loadChartData(name, 1);

		spawnedNotes = ChartParser.loadChartNotes(song);

		Conductor.callVocals(name);
		Conductor.changeBPM(song.bpm);
	}

	override public function create()
	{
		super.create();

		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			FlxG.sound.music.stop();

		gameplayMode = FREEPLAY;

		ScoreUtils.resetScore();

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		gameStage = new Stage();
		gameStage.setStage('stage');
		add(gameStage);

		opponent = new Character(false);
		opponent.setCharacter(100, 100, 'bf');
		add(opponent);

		player = new Character(true);
		player.setCharacter(770, 450, 'bf');
		add(player);

		Conductor.songPosition = -(Conductor.crochet * 5);

		storedNotes = new FlxTypedGroup<Note>();
		strumsGroup = new FlxTypedGroup<Strum>();

		storedNotes.cameras = [camHUD];
		strumsGroup.cameras = [camHUD];

		var height = (downscroll ? FlxG.height - 170 : 25);

		strumPlayer = new Strum((FlxG.width / 2) + FlxG.width / 4, height, [player]);
		strumOpponent = new Strum((FlxG.width / 2) - FlxG.width / 4 - 30, height, [opponent]);

		strumsGroup.add(strumPlayer);
		strumsGroup.add(strumOpponent);

		add(strumsGroup);
		add(storedNotes);

		gameUI = new UI();
		gameUI.cameras = [camHUD];
		add(gameUI);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(opponent.getMidpoint().x + 50, opponent.getMidpoint().x - 100);
		add(camFollow);

		cameraZoom = gameStage.cameraZoom;
		FlxG.camera.zoom = cameraZoom;

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		Controls.keyEventTrigger.add(keyEventTrigger);

		songCutscene();
	}

	public var countdownWasActive:Bool = false;
	public var skipCountdown:Bool = false;

	public function songCutscene()
	{
		for (strum in strumsGroup)
			strum.alpha = 0;

		isStartingSong = true;
		startCountdown();
	}

	var posCount:Int = 0;
	var posSong:Int = 4;

	public function startCountdown()
	{
		countdownWasActive = true;
		// canPause = true;

		Conductor.songPosition = -(Conductor.crochet * 5);

		if (skipCountdown)
		{
			Conductor.songPosition = -(Conductor.crochet * 1);
			startSong();
			return;
		}

		var introGraphicNames:Array<String> = ['prepare', 'ready', 'set', 'go'];
		var introSoundNames:Array<String> = ['intro3', 'intro2', 'intro1', 'introGo'];

		var introGraphics:Array<FlxGraphic> = [];
		var introSounds:Array<Sound> = [];

		for (graphic in introGraphicNames)
			introGraphics.push(AssetHandler.grabAsset(graphic, IMAGE, "images/ui/default"));

		for (sound in introSoundNames)
			introSounds.push(AssetHandler.grabAsset(sound, SOUND, "sounds/ui/default"));

		var introSprite:FlxSprite;
		var introSound:Sound;

		new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (introGraphics[posCount] != null)
			{
				introSprite = new FlxSprite().loadGraphic(introGraphics[posCount]);
				introSprite.scrollFactor.set();
				introSprite.updateHitbox();
				introSprite.screenCenter();
				add(introSprite);

				FlxTween.tween(introSprite, {y: introSprite.y += 50, alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						introSprite.destroy();
					}
				});
			}

			if (introSounds[posCount] != null)
			{
				introSound = introSounds[posCount];
				introSound.play();
			}

			// bop with countdown;
			charDancing();

			Conductor.songPosition = -(Conductor.crochet * posSong);

			posSong--;
			posCount++;
		}, 5);
	}

	function startSong()
	{
		Conductor.playSong(song.name);
		isStartingSong = false;
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE)
		{
			Conductor.stopSong();
			MusicState.switchState(new TitleState());
		}

		if (FlxG.keys.justPressed.FOUR)
		{
			isEndingSong = true;
			Conductor.stopSong();
			MusicState.switchState(new PlayState());
		}

		if (FlxG.keys.pressed.THREE)
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

		super.update(elapsed);

		if (isStartingSong)
		{
			Conductor.songPosition += elapsed * 1000;
			if (Conductor.songPosition >= 0 && countdownWasActive && !isEndingSong)
				startSong();
		}
		else
		{
			Conductor.songPosition += elapsed * 1000;
			if (Conductor.songPosition >= Conductor.lastSongPos)
				Conductor.lastSongPos = Conductor.songPosition;
		}

		FeatherUtils.cameraBumpingZooms(camGame, cameraZoom, cameraSpeed);
		FeatherUtils.cameraBumpingZooms(camHUD, 1);

		while (spawnedNotes[0] != null)
		{
			if (spawnedNotes[0].strumTime - Conductor.songPosition > 1800)
				break;

			storedNotes.add(spawnedNotes[0]);
			spawnedNotes.shift();
		}

		if (song != null)
		{
			if (song.sectionNotes != null && song.sectionNotes[curSection] != null)
			{
				var isMustHit:Bool = song.sectionNotes[curSection].cameraPoint == "player";

				var char:Character = isMustHit ? player : opponent;
				var pointX:Float = isMustHit ? char.getGraphicMidpoint().x - 100 : char.getGraphicMidpoint().x + 150;
				var pointY:Float = char.getMidpoint().y - 100;

				camFollow.setPosition(pointX + char.camOffset.x, pointY + char.camOffset.y);
			}

			for (strum in strumsGroup)
			{
				storedNotes.forEachAlive(function(note:Note)
				{
					var roundSpeed = FlxMath.roundDecimal(note.speed, 2);

					note.speed = song.speed;

					note.y = (strum.y - (Conductor.songPosition - note.strumTime) * (0.45 * roundSpeed));

					// i am so fucking sorry for this if condition
					if (note.isSustain
						&& note.y + note.offset.y <= strum.y + strum.babyArrows.members[note.index].swagWidth / 2
						&& (!note.mustPress || (note.wasGoodHit || (note.prevNote.wasGoodHit && !note.canBeHit))))
					{
						var swagRect = new FlxRect(0, strum.y + strum.babyArrows.members[note.index].swagWidth / 2 - note.y, note.width * 2, note.height * 2);
						swagRect.y /= note.scale.y;
						swagRect.height -= swagRect.y;

						note.clipRect = swagRect;
					}

					if (note.y > FlxG.height)
					{
						note.active = false;
						note.visible = false;
					}
					else
					{
						note.visible = true;
						note.active = true;
					}

					if ((note.mustPress && note.wasGoodHit) || (note.y < -note.height))
					{
						killNote(note);
						spawnedNotes.remove(note);
					}
				});
			}
		}
	}

	public function killNote(note:Note)
	{
		if (!note.canDie)
			return;

		note.active = false;
		note.exists = false;

		if (storedNotes.members.contains(note))
			storedNotes.remove(note, true);

		note.kill();
		note.destroy();
	}

	public function charDancing()
	{
		for (strum in strumsGroup)
		{
			for (i in strum.characters)
			{
				if (i != null && (i.animOffsets.exists(i.defaultIdle)))
					i.dance();
			}
		}
	}

	override function beatHit()
	{
		charDancing();

		FeatherUtils.cameraBumpReset(curBeat, camGame, bumpSpeed, 0.015);
		FeatherUtils.cameraBumpReset(curBeat, camHUD, bumpSpeed, 0.05);

		super.beatHit();
	}

	override function stepHit()
	{
		Conductor.stepResync();

		super.stepHit();
	}

	override function sectionHit()
	{
		super.sectionHit();
	}

	override function endSong()
	{
		super.endSong();

		MusicState.switchState(new PlayState());
	}

	public function keyEventTrigger(action:String, key:Int, state:KeyState)
	{
		switch (action)
		{
			case "left" | "down" | "up" | "right":
				var actions = ["left", "down", "up", "right"];
				var index = actions.indexOf(action);
				inputSystem(index, state);
		}
	}

	var keysHeld:Array<Bool> = [];

	public function inputSystem(idx:Int, state:KeyState)
	{
		keysHeld[idx] = (state == PRESSED);
		// trace(keysHeld);

		if (state == PRESSED)
		{
			if (song != null)
			{
				var noteList:Array<Note> = [];
				var notePresses:Array<Note> = [];

				storedNotes.forEachAlive(function(note:Note)
				{
					if ((note.index == idx) && note.mustPress && note.canBeHit && !note.isSustain && !note.tooLate && !note.wasGoodHit)
						noteList.push(note);
				});
				noteList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if (noteList.length > 0)
				{
					for (note in noteList)
					{
						noteHit(note, strumPlayer);
						notePresses.push(note);
					}
				}
			}

			if (strumPlayer.babyArrows.members[idx] != null && strumPlayer.babyArrows.members[idx].animation.curAnim.name != 'confirm')
				strumPlayer.babyArrows.members[idx].playAnim('pressed');
		}
		else
		{
			if (idx >= 0 && strumPlayer.babyArrows.members[idx] != null)
				strumPlayer.babyArrows.members[idx].playAnim('static');
		}
	}

	public function noteHit(note:Note, strum:Strum)
	{
		if (!note.wasGoodHit)
		{
			note.wasGoodHit = true;
			strum.babyArrows.members[note.index].playAnim('confirm', true);

			for (c in strum.characters)
			{
				if (c != null)
					c.playAnim(c.defaultSingAnims[note.index], true);
			}
			ScoreUtils.increaseCombo();
		}

		gameUI.updateScoreBar();
	}

	override public function destroy()
	{
		Controls.keyEventTrigger.remove(keyEventTrigger);
		super.destroy();
	}
}
