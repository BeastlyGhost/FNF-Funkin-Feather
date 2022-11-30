package states;

import base.song.*;
import base.song.MusicState.MusicBeatState;
import base.song.SongFormat.FeatherSong;
import base.utils.*;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import objects.Character;
import objects.Stage;
import objects.ui.*;
import objects.ui.Note.Notefield;
import openfl.media.Sound;

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
	public static var song(default, set):FeatherSong;
	@:isVar public static var songSpeed(get, default):Float = 1; // this needs to be a `get, set` later

	public static function set_song(newSong:FeatherSong):FeatherSong
	{
		if (newSong != null && song != newSong)
		{
			// clear notes prior to storing new ones
			if (notesGroup != null)
				notesGroup.destroy();
			spawnedNotes = [];

			song = newSong;
			songSpeed = song.speed;

			Conductor.callVocals(song.name);
			Conductor.changeBPM(song.bpm);

			spawnedNotes = ChartParser.loadChartNotes(song);

			Conductor.songPosition = -(Conductor.crochet * 5);
		}

		return song;
	}

	public static function get_songSpeed()
		return FlxMath.roundDecimal(songSpeed, 2);

	public static var songName:String;
	public static var difficulty:Int;

	// User Interface
	public static var strumsGroup:FlxTypedGroup<Strum>;

	public static var notesGroup:Notefield;
	public static var spawnedNotes:Array<Note>;

	public static var gameUI:UI;

	public var strumsP1:Strum;
	public var strumsP2:Strum;

	public static var assetSkin:String = 'default';

	// how big to stretch the pixel assets
	public static var pixelAssetSize:Float = 6;

	// Characters
	public var player:Player;
	public var crowd:Character;
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

	override public function create()
	{
		super.create();

		FlxG.mouse.visible = false;
		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			FlxG.sound.music.stop();

		PlayerUtils.resetScore();

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

		// generate the song
		song = ChartParser.loadChartData(songName, difficulty);

		gameStage.setStage('stage');
		add(gameStage);

		opponent.setCharacter(100, 100, 'bf');
		add(opponent);

		player.setCharacter(770, 450, 'bf');
		add(player);

		strumsGroup = new FlxTypedGroup<Strum>();
		notesGroup = new Notefield();

		strumsGroup.cameras = [camHUD];
		notesGroup.cameras = [camHUD];

		var height = (downscroll ? FlxG.height - 170 : 25);

		strumsP1 = new Strum((FlxG.width / 2) + FlxG.width / 4, height, [player], false);
		strumsP2 = new Strum((FlxG.width / 2) - FlxG.width / 4 - 30, height, [opponent], true);

		strumsGroup.add(strumsP1);
		strumsGroup.add(strumsP2);

		add(strumsGroup);
		add(notesGroup);

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
		changePresence();
	}

	public static function changePresence(addString:String = '')
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

		lineRPC2 = '${FeatherUtils.coolSongFormatter(song.name)} [${stringDiff.replace('-', '').toUpperCase()}]';

		DiscordRPC.update(addString + lineRPC1, mode + ' - ' + lineRPC2);
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

		// cache ratings
		popUpScore('sick', true);

		if (countdownWasActive && !isPaused && !hasDied && skipCountdown)
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
			charDancing(curBeat);

			if (!isPaused && !hasDied)
				Conductor.songPosition = -(Conductor.crochet * posSong);

			posSong -= 1;
			posCount += 1;

			if (posCount == 4)
				gameUI.showInfoCard();
		}, 5);
	}

	function startSong()
	{
		if (posCount >= 4 && countdownWasActive && !isEndingSong)
		{
			AssetHandler.clear(false, false);

			Conductor.playSong(song.name);
			isStartingSong = false;
		}
	}

	override public function update(elapsed:Float)
	{
		if (gameplayMode != STORY)
		{
			if (FlxG.keys.justPressed.SEVEN)
			{
				Conductor.stopSong();
				MusicState.switchState(new states.editors.ChartEditor());
			}
		}

		super.update(elapsed);

		if (!isPaused && !hasDied)
		{
			Conductor.songPosition += elapsed * 1000;
			if (Conductor.songPosition >= Conductor.lastSongPos)
				Conductor.lastSongPos = Conductor.songPosition;

			if (isStartingSong)
				if (Conductor.songPosition >= 0)
					startSong();
		}

		FeatherUtils.cameraBumpingZooms(camGame, cameraZoom, cameraSpeed);
		FeatherUtils.cameraBumpingZooms(camHUD, 1);

		playerDeathCheck();

		if (Controls.getPressEvent("pause") && canPause)
		{
			isPaused = true;
			Conductor.pauseSong();
			globalManagerPause();
			changePresence("Paused - ");
			openSubState(new states.substates.PauseSubstate(player.getScreenPosition().x, player.getScreenPosition().y));
		}

		while (spawnedNotes[0] != null)
		{
			if (spawnedNotes[0].strumTime - Conductor.songPosition > 1800)
				break;

			notesGroup.add(spawnedNotes[0]);
			spawnedNotes.shift();
		}

		if (song != null && countdownWasActive)
		{
			for (strum in strumsGroup)
			{
				notesGroup.forEachAlive(function(note:Note)
				{
					for (babyArrow in strum.babyArrows)
					{
						if (strum.autoplay && babyArrow.animation.curAnim.name == 'confirm' && babyArrow.animation.curAnim.finished)
							babyArrow.playAnim('static', true);
					}

					note.speed = songSpeed;

					notesGroup.updateRects(note, strum);

					if (strum.autoplay)
					{
						if (!note.mustPress && note.strumTime <= Conductor.songPosition)
							noteHit(note, strum);
					}
					else if (!strum.autoplay)
					{
						if (keysHeld.contains(true))
						{
							if (note.canBeHit && note.mustPress && !note.tooLate && note.isSustain && keysHeld[note.index])
								noteHit(note, strum);
						}
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

					if (!note.tooLate && !note.wasGoodHit && note.strumTime < Conductor.songPosition - (PlayerUtils.timingThreshold))
					{
						if ((!note.tooLate) && (note.mustPress))
						{
							note.tooLate = true;

							if (note.ignoreNote || !note.isMine)
								return;

							noteMiss(note.index, strum);
						}
					}

					var deathRange = (downscroll ? FlxG.height + note.height : -note.height);

					// kill offscreen notes
					if (note.y < deathRange)
					{
						notesGroup.removeNote(note);
						spawnedNotes.remove(note);
					}
				});
			}
		}
	}

	private var hasDied:Bool = false;

	public function playerDeathCheck():Bool
	{
		if (PlayerUtils.health <= 0 && !hasDied)
		{
			isPaused = true;
			Conductor.stopSong(); // *beep boops stop*
			PlayerUtils.deaths++;
			hasDied = true;

			persistentUpdate = false;
			persistentDraw = false;

			globalManagerPause();

			FlxG.sound.play(AssetHandler.grabAsset("fnf_loss_sfx", SOUND, "sounds/" + assetSkin));

			changePresence("Dead - ");
			return true;
		}
		return false;
	}

	public function keyEventTrigger(action:String, key:Int, state:KeyState)
	{
		if (isPaused || strumsP1.autoplay)
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
			if (song != null && countdownWasActive && !isEndingSong)
			{
				var noteList:Array<Note> = [];
				var notePresses:Array<Note> = [];
				var notePossible:Bool = true; // usually, yeah, it should be possible to hit a note

				notesGroup.forEachAlive(function(note:Note)
				{
					if ((note.index == idx) && !note.isSustain && !note.tooLate && !note.wasGoodHit && note.mustPress && note.canBeHit)
						noteList.push(note);
					// trace("Stored Note List: " + noteList);
				});
				noteList.sort(sortHitNotes);

				if (noteList.length > 0)
				{
					for (note in noteList)
					{
						for (pressedNote in notePresses)
						{
							if (Math.abs(pressedNote.strumTime - note.strumTime) < 1)
							{
								// kill the note
								notesGroup.removeNote(pressedNote);
								spawnedNotes.remove(pressedNote);
							}
							else // declare as not possible to hit
								notePossible = false;
						}

						if (notePossible)
						{
							noteHit(note, strumsP1);
							notePresses.push(note);
						}
					}
				}
				else
				{
					if (!OptionsMeta.getPref("Ghost Tapping"))
					{
						noteMiss(idx, strumsP1);
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
			if (player.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !keysHeld.contains(true))
			{
				if (player.animation.curAnim.name.startsWith('sing') && !player.animation.curAnim.name.endsWith('miss'))
					player.dance();
			}
		}
	}

	/**
		Sort through possible notes
		@author Shadow_Mario_
	**/
	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	public function noteHit(note:Note, strum:Strum)
	{
		if (!note.wasGoodHit)
		{
			note.wasGoodHit = true;

			if (strum.babyArrows.members[note.index].glowNoteHits)
				strum.babyArrows.members[note.index].playAnim('confirm', true);

			var stringAnim:String = '';
			var section = song.sectionNotes[curSection];

			// paunful if statement
			if (section != null)
				if (section.animation != null && section.animation != '')
					stringAnim = section.animation;

			for (char in strum.characters)
			{
				if (char != null)
				{
					char.playAnim(char.singAnims[note.index] + stringAnim, true);
					char.holdTimer = 0;
				}
			}

			var lowestDiff:Float = Math.POSITIVE_INFINITY;
			var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);
			var ratingInteger:Int = 3; // 3 is "Shit"

			if (note.mustPress && !strum.autoplay) // being hit by the player
			{
				for (i in 0...PlayerUtils.judgeTable.length)
				{
					var timingMod:Float = PlayerUtils.judgeTable[i].timingMod;
					if (noteDiff <= timingMod && (timingMod < lowestDiff))
					{
						ratingInteger = i;
						lowestDiff = timingMod;
					}

					if (i > PlayerUtils.greatestJudgement)
						PlayerUtils.greatestJudgement = i;
				}

				if (!note.isSustain)
				{
					PlayerUtils.increaseScore(ratingInteger);
					popUpScore(PlayerUtils.judgeTable[ratingInteger].name);

					// update scoretext
					gameUI.updateScoreBar();
				}
			}

			if (!note.isSustain)
			{
				notesGroup.removeNote(note);
				spawnedNotes.remove(note);
			}
		}
	}

	public function noteMiss(idx:Int, strum:Strum)
	{
		if (crowd != null)
		{
			if (PlayerUtils.combo >= 5)
				if (crowd.animOffsets.exists("sad"))
					crowd.playAnim("sad");
		}

		for (char in strum.characters)
		{
			if (char != null && char.hasMissAnims)
				char.playAnim(char.singAnims[idx] + 'miss');
		}
		FlxG.sound.play(AssetHandler.grabAsset("miss" + FlxG.random.int(1, 3), SOUND, "sounds/" + assetSkin), FlxG.random.float(0.1, 0.2));

		PlayerUtils.decreaseScore();
		gameUI.updateScoreBar();
	}

	public function popUpScore(myRating:String = 'sick', preload:Bool = false)
	{
		var rating:FlxSprite = PlayerUtils.generateRating(assetSkin);

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

		var stringCombo:String = Std.string(PlayerUtils.combo);
		var splitCombo:Array<String> = stringCombo.split("");

		for (i in 0...splitCombo.length)
		{
			var numScore:FlxSprite = PlayerUtils.generateCombo(assetSkin);

			numScore.alpha = 1;
			numScore.screenCenter();
			numScore.x += (43 * i) + 20;
			numScore.y += 60;

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y = -FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
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

	public function charDancing(beat:Int)
	{
		for (strum in strumsGroup)
		{
			for (i in strum.characters)
			{
				if (beat % i.bopTimer == 0 && i != null && (i.animOffsets.exists(i.defaultIdle)))
					i.dance();
			}
		}
	}

	override function beatHit()
	{
		charDancing(curBeat);

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
		changePresence();
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
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();
				FeatherUtils.menuMusicCheck(false);
				MusicState.switchState(new states.menus.MainMenu());
		}
	}

	override public function destroy()
	{
		Controls.keyEventTrigger.remove(keyEventTrigger);
		super.destroy();
	}
}
