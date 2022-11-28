package states;

import base.song.*;
import base.song.MusicState.MusicBeatState;
import base.song.SongFormat.CyndaSong;
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
import flixel.util.FlxTimer;
import haxe.Json;
import objects.Character;
import objects.Stage;
import objects.ui.*;
import openfl.media.Sound;
import openfl.net.FileReference;

enum GameModes
{
	STORY;
	FREEPLAY;
	CHARTING;
}

/**
	basically the "heart" of the game, `PlayState` tends to get functions from a existing class,
	and actually give it a proper purpose, like playing a song and displaying the scrolling notes
**/
class PlayState extends MusicBeatState
{
	// Song
	public static var song:CyndaSong;

	public static var songName:String;
	public static var difficulty:Int;

	public static var songSpeed:Float = 1;

	// User Interface
	public static var strumsGroup:FlxTypedGroup<Strum>;

	public static var storedNotes:FlxTypedGroup<Note>;
	public static var spawnedNotes:Array<Note>;

	public static var gameUI:UI;

	public var strumsP1:Strum;
	public var strumsP2:Strum;

	public static var assetSkin:String = 'default';

	// how big to stretch the pixel assets
	public static var pixelAssetSize:Float = 6;

	// Characters
	public var player:Player;
	public var spectator:Character;
	public var opponent:Character;

	public var gameStage:Stage;

	// Camera
	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;

	private var camFollow:FlxObject;

	public static var cameraSpeed:Float = 1;
	public static var cameraZoom:Float = 1.05;
	public static var bumpSpeed:Float = 4;

	// Gameplay and Events
	public static var gameplayMode:GameModes;

	// Discord RPC variables
	public static var lineRPC1:String = '';
	public static var lineRPC2:String = '';

	public var downscroll:Bool = false;

	public static function generateSong(?name:String, ?diff:Int):Void
	{
		if (name == null)
			name = 'bopeebo';

		if (diff < 0 || diff == null)
			diff = 1;

		// clear notes prior to storing new ones
		if (storedNotes != null)
			storedNotes.destroy();
		spawnedNotes = [];

		song = ChartParser.loadChartData(name, 1);

		spawnedNotes = ChartParser.loadChartNotes(song);

		songSpeed = song.speed;

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

		// initialize main variales
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();

		gameStage = new Stage();
		opponent = new Character(false);
		player = new Player();

		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		gameStage.setStage('stage');
		add(gameStage);

		opponent.setCharacter(100, 100, 'bf');
		add(opponent);

		player.setCharacter(770, 450, 'bf');
		add(player);

		generateSong(songName, difficulty);

		strumsGroup = new FlxTypedGroup<Strum>();
		storedNotes = new FlxTypedGroup<Note>();

		strumsGroup.cameras = [camHUD];
		storedNotes.cameras = [camHUD];

		var height = (downscroll ? FlxG.height - 170 : 25);

		strumsP1 = new Strum((FlxG.width / 2) + FlxG.width / 4, height, [player], false);
		strumsP2 = new Strum((FlxG.width / 2) - FlxG.width / 4 - 30, height, [opponent], true);

		strumsGroup.add(strumsP1);
		strumsGroup.add(strumsP2);

		add(strumsGroup);
		add(storedNotes);

		gameUI = new UI();
		gameUI.cameras = [camHUD];
		add(gameUI);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(player.getMidpoint().x + 50, player.getMidpoint().y - 100);
		add(camFollow);

		cameraZoom = gameStage.cameraZoom;
		FlxG.camera.zoom = cameraZoom;

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		Controls.keyEventTrigger.add(keyEventTrigger);

		songCutscene();
		changePresence(isPaused);
	}

	public static function changePresence(paused:Bool)
	{
		var mode:String = 'Freeplay';

		switch (gameplayMode)
		{
			case STORY:
				mode = "Story Mode";
			case FREEPLAY | CHARTING:
				mode = "Freeplay";
		}

		var stringDiff = ChartParser.difficultyMap.get(difficulty);

		lineRPC2 = '${FeatherUtils.coolSongFormatter(PlayState.song.name)} [${stringDiff.replace('-', '').toUpperCase()}]';

		if (paused)
			DiscordRPC.update("Paused - " + lineRPC1, mode + ' - ' + lineRPC2);
		else
			DiscordRPC.update(lineRPC1, mode + ' - ' + lineRPC2);
	}

	public var canPause:Bool = false;
	public var isPaused:Bool = false;
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
		canPause = true;

		Conductor.songPosition = -(Conductor.crochet * 5);

		// cache ratings
		popUpScore('sick', true);

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
			introGraphics.push(AssetHandler.grabAsset(graphic, IMAGE, "images/ui/" + assetSkin));

		for (sound in introSoundNames)
			introSounds.push(AssetHandler.grabAsset(sound, SOUND, "sounds/" + assetSkin));

		var introSprite:FlxSprite;

		new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (introGraphics[posCount] != null)
			{
				introSprite = new FlxSprite().loadGraphic(introGraphics[posCount]);
				introSprite.scrollFactor.set();
				introSprite.updateHitbox();
				introSprite.screenCenter();
				add(introSprite);

				if (assetSkin == "pixel")
				{
					introSprite.setGraphicSize(Std.int(introSprite.width * pixelAssetSize));
					introSprite.antialiasing = false;
				}

				FlxTween.tween(introSprite, {y: introSprite.y += 50, alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						introSprite.destroy();
					}
				});
			}

			if (introSounds[posCount] != null)
				FlxG.sound.play(introSounds[posCount]);

			// bop with countdown;
			charDancing();

			Conductor.songPosition = -(Conductor.crochet * posSong);

			posSong--;
			posCount++;

			if (posCount == 4)
				gameUI.showInfoCard();
		}, 5);
	}

	function startSong()
	{
		AssetHandler.clear(false, false);
		Conductor.playSong(song.name);
		isStartingSong = false;
	}

	override public function update(elapsed:Float)
	{
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

		if (gameplayMode != STORY)
		{
			if (FlxG.keys.justPressed.SEVEN)
			{
				Conductor.stopSong();
				MusicState.switchState(new states.editors.ChartEditor());
			}
		}

		super.update(elapsed);

		if (!isPaused)
		{
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

		if (Controls.getPressEvent("pause") && canPause)
		{
			isPaused = true;
			Conductor.pauseSong();
			globalManagerPause();
			changePresence(true);
			openSubState(new states.substates.PauseSubstate(player.getScreenPosition().x, player.getScreenPosition().y));
		}

		if (song != null && countdownWasActive)
		{
			for (strum in strumsGroup)
			{
				storedNotes.forEachAlive(function(note:Note)
				{
					for (babyArrow in strum.babyArrows)
					{
						if (babyArrow.animation.curAnim.name == 'confirm' && babyArrow.animation.curAnim.finished)
							babyArrow.playAnim('static', true);
					}

					note.speed = song.speed;

					note.y = (strum.y - (Conductor.songPosition - note.strumTime) * (0.45 * FlxMath.roundDecimal(note.speed, 2)));

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

					if (strum.autoplay && note.strumTime <= Conductor.songPosition)
					{
						for (char in strum.characters)
							noteHit(note, strum, char);
					}

					if (!note.tooLate && note.strumTime < Conductor.songPosition /* - (ScoreUtils.safeZoneOffset) */ && !note.wasGoodHit)
					{
						if ((!note.tooLate) && (note.mustPress))
						{
							if (!note.isSustain)
							{
								note.tooLate = true;

								if (note.ignoreNote || !note.isMine)
									return;

								for (char in strum.characters)
									noteMiss(note.index, char);
							}
						}
					}
					var deathRange = (downscroll ? FlxG.height + note.height : -note.height);

					// kill offscreen notes
					if ((note.y < deathRange) || (/*note.tooLate || */ note.wasGoodHit))
					{
						killNote(note);
						spawnedNotes.remove(note);
					}
				});
			}
		}
	}

	public function keyEventTrigger(action:String, key:Int, state:KeyState)
	{
		if (isPaused)
			return;

		switch (action)
		{
			case "left" | "down" | "up" | "right":
				var actions = ["left", "down", "up", "right"];
				var index = actions.indexOf(action);
				inputSystem(index, state);
		}
	}

	var keysHeld:Array<Bool> = [];

	// idx is shortehand for index
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
					// trace("Stored Note List: " + noteList);
				});
				noteList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if (noteList.length > 0)
				{
					var notePossible:Bool = true;

					for (note in noteList)
					{
						for (pressedNote in notePresses)
						{
							if (pressedNote != null && (pressedNote.strumTime - note.strumTime) > 10)
								notePossible = false;
						}

						if (notePossible)
						{
							noteHit(note, strumsP1, player);
							notePresses.push(note);
						}
					}
				}
				else
				{
					if (!OptionsMeta.getPref("Ghost Tapping"))
					{
						for (char in strumsP1.characters)
							if (char != null)
								noteMiss(idx, char);
					}
				}
			}

			if (strumsP1.babyArrows.members[idx] != null && strumsP1.babyArrows.members[idx].animation.curAnim.name != 'confirm')
				strumsP1.babyArrows.members[idx].playAnim('pressed');
		}
		else
		{
			if (idx >= 0 && strumsP1.babyArrows.members[idx] != null)
				strumsP1.babyArrows.members[idx].playAnim('static');

			if (player.holdTimer > Conductor.stepCrochet * 4 * 0.001 && keysHeld.contains(true))
			{
				if (player.animation.curAnim.name.startsWith('sing') && !player.animation.curAnim.name.endsWith('miss'))
					player.dance();
			}
		}
	}

	public function noteHit(note:Note, strum:Strum, char:Character)
	{
		if (!note.wasGoodHit)
		{
			note.wasGoodHit = true;
			strum.babyArrows.members[note.index].playAnim('confirm', true);

			if (char != null)
			{
				char.playAnim(char.singAnims[note.index]);
				char.holdTimer = 0;
			}

			var lowestDiff:Float = Math.POSITIVE_INFINITY;
			var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);
			var ratingInteger:Int = 4;

			for (i in 0...ScoreUtils.judgeTable.length)
			{
				var timingMod:Float = ScoreUtils.judgeTable[i].timingMod;
				if (noteDiff <= timingMod && (timingMod < lowestDiff))
				{
					ratingInteger = i;
					lowestDiff = timingMod;
				}

				if (i > ScoreUtils.highestJudgement)
					ScoreUtils.highestJudgement = i;
			}

			if (!strum.autoplay && note.mustPress && !note.isSustain)
			{
				ScoreUtils.increaseScore(ratingInteger);
				popUpScore(ScoreUtils.judgeTable[ratingInteger].name);

				// update scoretext
				gameUI.updateScoreBar();
			}

			if (!note.isSustain)
			{
				killNote(note);
				spawnedNotes.remove(note);
			}
		}
	}

	public function noteMiss(idx:Int, character:Character)
	{
		if (character.hasMissAnims)
			character.playAnim(character.singAnims[idx] + 'miss');
		FlxG.sound.play(AssetHandler.grabAsset("miss" + FlxG.random.int(1, 3), SOUND, "sounds/" + assetSkin));

		ScoreUtils.decreaseScore();
		gameUI.updateScoreBar();
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

	public function popUpScore(myRating:String = 'sick', preload:Bool = false)
	{
		var rating:FlxSprite = ScoreUtils.generateRating(assetSkin);

		rating.screenCenter();
		rating.x = (FlxG.width * 0.55) - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		add(rating);

		if (preload)
			rating.alpha = 0.000001;

		rating.animation.play(myRating);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			onComplete: t ->
			{
				rating.kill();
			},
			startDelay: Conductor.crochet * 0.001
		});

		var stringCombo:String = Std.string(ScoreUtils.combo);
		var splitCombo:Array<String> = stringCombo.split("");

		for (i in 0...splitCombo.length)
		{
			var numScore:FlxSprite = ScoreUtils.generateCombo(assetSkin);

			numScore.alpha = 1;
			numScore.screenCenter();
			numScore.x += (43 * i) + 20;
			numScore.y += 60;

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y = -FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (ScoreUtils.combo >= 5)
				add(numScore);

			if (preload)
				numScore.alpha = 0.000001;

			numScore.animation.play("num" + splitCombo[i]);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: t ->
				{
					numScore.kill();
				},
				startDelay: Conductor.crochet * 0.002
			});
		}
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

		gameUI.updateIconScale();

		super.beatHit();
	}

	override function stepHit()
	{
		Conductor.stepResync();

		super.stepHit();
	}

	override function closeSubState()
	{
		isPaused = false;
		changePresence(false);
		super.closeSubState();
	}

	public function globalManagerPause()
	{
		// stop all tweens and timers
		FlxTimer.globalManager.forEach(function(tmr:FlxTimer)
		{
			if (!tmr.finished)
				tmr.active = false;
		});

		FlxTween.globalManager.forEach(function(twn:FlxTween)
		{
			if (!twn.finished)
				twn.active = false;
		});
	}

	override function endSong()
	{
		super.endSong();

		switch (gameplayMode)
		{
			default:
				MusicState.switchState(new TitleState());
		}
	}

	override public function destroy()
	{
		Controls.keyEventTrigger.remove(keyEventTrigger);
		super.destroy();
	}
}
