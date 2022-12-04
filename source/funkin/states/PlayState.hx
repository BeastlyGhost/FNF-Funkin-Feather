package funkin.states;

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
import funkin.backend.dependencies.FeatherModule;
import funkin.backend.dependencies.PlayerInfo;
import funkin.objects.Character;
import funkin.objects.Stage;
import funkin.objects.ui.*;
import funkin.objects.ui.notes.*;
import funkin.song.ChartParser;
import funkin.song.Conductor;
import funkin.song.MusicState;
import funkin.song.SongFormat.FeatherSong;
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
	public static var main:PlayState;
	public static var modules:Array<FeatherModule> = [];

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

			if (FlxG.sound.music != null && FlxG.sound.music.playing)
				FlxG.sound.music.stop();

			song = newSong;
			songSpeed = song.speed;

			Conductor.callVocals(song.name);
			Conductor.changeBPM(song.bpm);
			// Conductor.mapBPMChanges(song);

			spawnedNotes = ChartParser.loadChartNotes(song);
		}

		return song;
	}

	public static function get_songSpeed()
		return FlxMath.roundDecimal(songSpeed, 2);

	public static var songName:String;
	public static var difficulty:Int;

	public static var songPlaylist:Array<String> = [];

	// User Interface
	public static var strumsGroup:FlxTypedGroup<Strum>;
	public static var notesGroup:Notefield;
	public static var splashGroup:FlxTypedGroup<NoteSplash>;
	public static var spawnedNotes:Array<Note>;

	public static var gameUI:UI;

	public static var strumsP1:Strum;
	public static var strumsP2:Strum;

	public var playerStrum:Array<Strum> = [];

	public static var assetSkin:String = 'default';

	// how big to stretch the pixel assets
	public static var pixelAssetSize:Float = 6;

	// Characters
	public var player:Character;
	public var crowd:Character;
	public var opponent:Character;

	public var crowdSpeed:Int = 1;

	public var gameStage:Stage;
	public var curStage:String = '';

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

	override public function create()
	{
		super.create();

		main = this;

		FlxG.mouse.visible = false;

		PlayerInfo.resetScore();

		// initialize main variales
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();

		gameStage = new Stage();

		opponent = new Character();
		crowd = new Character();
		player = new Character();

		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		// generate the song
		song = ChartParser.loadChartData(songName, difficulty);

		FeatherModule.initArray(modules);

		gameStage.setStage('stage');
		add(gameStage);

		curStage = gameStage.getStageName();

		crowd.setCharacter(300, 100, 'bf');
		add(crowd);

		opponent.setCharacter(100, 100, song.opponent);
		add(opponent);

		player.setCharacter(770, 450, 'bf');
		add(player);

		strumsGroup = new FlxTypedGroup<Strum>();
		splashGroup = new FlxTypedGroup<NoteSplash>();
		notesGroup = new Notefield();

		strumsGroup.cameras = [camHUD];
		splashGroup.cameras = [camHUD];
		notesGroup.cameras = [camHUD];

		var isDownscroll = OptionsMeta.getPref("Downscroll");
		var height = (isDownscroll ? FlxG.height - 170 : 25);

		strumsP1 = new Strum((FlxG.width / 2) + FlxG.width / 4, height, [player], false, isDownscroll);
		strumsP2 = new Strum((FlxG.width / 2) - FlxG.width / 4 - 30, height, [opponent], true, isDownscroll);

		strumsGroup.add(strumsP1);
		strumsGroup.add(strumsP2);

		playerStrum = [strumsP1];

		add(strumsGroup);
		add(splashGroup);
		add(notesGroup);

		var firework:NoteSplash = new NoteSplash(100, 100, 0);
		firework.alpha = 0.000001;
		splashGroup.add(firework);

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

		callFunc('postCreate', []);
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

		var stringDiff = FeatherTools.getDifficulty(difficulty);

		lineRPC2 = '${FeatherTools.formatSong(song.name)} [${stringDiff.replace('-', '').toUpperCase()}]';

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

		Conductor.songPosition = -(Conductor.crochet * 16);

		callFunc('songCutscene' + (isEndingSong ? 'End' : ''), []);

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

		callFunc('startCountdown', []);

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
			gameStage.stageCountdownTick(curBeat, player, opponent, crowd);

			if (!isPaused && !hasDied)
				Conductor.songPosition = -(Conductor.crochet * posSong);

			posSong -= 1;
			posCount += 1;

			callFunc('countdownTick', [posCount]);

			if (posCount == 4)
				gameUI.showInfoCard();
		}, 5);
	}

	function startSong()
	{
		callFunc('startSong', []);

		AssetHandler.clear(false, false);

		Conductor.playSong(song.name);
		isStartingSong = false;
	}

	inline public function cameraMovePoint(character:String = 'player')
	{
		var char:Character = opponent;

		switch (character)
		{
			case "player" | "bf" | "boyfriend":
				char = player;
			case "crowd" | "spectator" | "girlfriend" | "gf":
				char = crowd;
			case "opponent" | "dad" | "dadOpponent":
				char = opponent;
		}

		var pointX = character == "player" ? char.getMidpoint().x - 100 : char.getMidpoint().x + 100;
		var pointY = char.getMidpoint().y - 100;

		camFollow.setPosition(pointX + char.camOffset.x, pointY + char.camOffset.y);
	}

	override public function update(elapsed:Float)
	{
		callFunc('update', [elapsed]);

		super.update(elapsed);

		gameStage.stageUpdate(elapsed, player, opponent, crowd);

		if (!isPaused && !hasDied && !isEndingSong)
		{
			if (gameplayMode != STORY)
			{
				if (FlxG.keys.justPressed.SIX)
				{
					strumsP1.autoplay = !strumsP1.autoplay;
					gameUI.autoPlayText.visible = strumsP1.autoplay;
				}

				if (FlxG.keys.justPressed.SEVEN)
				{
					PlayerInfo.validScore = false;
					gameplayMode = CHARTING;
					Conductor.stopSong();
					MusicState.switchState(new funkin.states.editors.ChartEditor());
				}
			}

			Conductor.songPosition += elapsed * 1000;
			if (Conductor.songPosition >= 0 && !Conductor.songMusic.playing && !isStartingSong)
				startSong();

			if (Conductor.songPosition > Conductor.lastSongPos)
				Conductor.lastSongPos = Conductor.songPosition;
		}

		FeatherTools.cameraBumpingZooms(camGame, cameraZoom, cameraSpeed);
		FeatherTools.cameraBumpingZooms(camHUD, 1);

		if (song != null && song.sectionNotes != null && song.sectionNotes[Std.int(curStep / 16)] != null)
			cameraMovePoint(song.sectionNotes[Std.int(curStep / 16)].cameraPoint);

		playerDeathCheck();

		if (Controls.getPressEvent("pause", "justPressed") && canPause)
		{
			isPaused = true;
			Conductor.pauseSong();
			globalManagerPause();
			changePresence("Paused - ");
			openSubState(new funkin.substates.PauseSubstate(player.getScreenPosition().x, player.getScreenPosition().y, "default"));
		}

		while (spawnedNotes[0] != null)
		{
			if (spawnedNotes[0].step - Conductor.songPosition > 1800)
				break;

			notesGroup.add(spawnedNotes[0]);
			spawnedNotes.shift();
		}

		if (song != null)
		{
			if (countdownWasActive)
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
						note.downscroll = strum.downscroll;

						notesGroup.updateRects(note, strum);

						/*
							if (strum.autoplay)
							{
								if (note.step <= Conductor.songPosition)
									noteHit(note, strum);
							}
							// redoing this later
						**/

						var killRangeReached:Bool = (note.downscroll ? note.y > FlxG.height : note.y < -note.height);

						// kill offscreen notes and cause misses if needed
						if (Conductor.songPosition > note.missOffset + note.step)
						{
							note.active = false;
							note.visible = false;

							if (killRangeReached)
							{
								notesGroup.removeNote(note);
								spawnedNotes.remove(note);
							}

							if (note.mustPress && !note.isSustain && !note.tooLate && !note.wasGoodHit && !note.isMine && !note.ignoreNote)
							{
								note.tooLate = true;
								noteMiss(note.index, strum);
							}
						}
					});
				}
			}
			else
			{
				// prevent hits if the countdown was not active
				notesGroup.forEachAlive(function(note:Note)
				{
					note.canBeHit = false;
					note.wasGoodHit = false;
				});
			}
		}

		callFunc('postUpdate', [elapsed]);
	}

	private var hasDied:Bool = false;

	public function playerDeathCheck():Bool
	{
		if (PlayerInfo.health <= 0 && !hasDied)
		{
			isPaused = true;
			Conductor.stopSong(); // *beep boops stop*
			PlayerInfo.deaths++;
			hasDied = true;

			callFunc('onDeath', []);

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
		if (isPaused || isEndingSong)
			return;

		switch (action)
		{
			case "left" | "down" | "up" | "right":
				var actions = ["left", "down", "up", "right"];
				var index = actions.indexOf(action);
				inputSystem(index, state);
		}
		callFunc('onKey' + (state == PRESSED ? 'Press' : 'Release'), [key, action]);
	}

	var keysHeld:Array<Bool> = [];

	// idx is shortehand for index
	public function inputSystem(idx:Int, state:KeyState)
	{
		keysHeld[idx] = (state == PRESSED);
		// trace(keysHeld);

		for (strum in playerStrum)
		{
			// shortening
			var babyArrow:BabyArrow = strum.babyArrows.members[idx];

			if (state == PRESSED)
			{
				if (song != null && !strum.autoplay && countdownWasActive)
				{
					/*
						hold notes
					**/

					if (keysHeld.contains(true))
					{
						notesGroup.forEachAlive(function(note:Note)
						{
							if (note.canBeHit && note.mustPress && note.isSustain && !note.tooLate && keysHeld[note.index])
								noteHit(note, strum);
						});
					}

					/*
						normal notes
					**/

					var prevTime:Float = Conductor.songPosition;

					Conductor.songPosition = Conductor.songMusic.time;

					var noteList:Array<Note> = [];
					var notePresses:Array<Note> = [];

					notesGroup.forEachAlive(function(note:Note)
					{
						if ((note.index == idx) && note.mustPress && note.canBeHit && !note.isSustain && !note.tooLate && !note.wasGoodHit)
							noteList.push(note);
						// trace("Stored Note List: " + noteList);
					});
					noteList.sort(sortHitNotes);

					if (noteList.length > 0)
					{
						var notePossible:Bool = true; // usually, yeah, it should be possible to hit a note

						for (epicNote in noteList)
						{
							for (troubleNote in notePresses)
							{
								if (Math.abs(epicNote.step - troubleNote.step) > 10)
									notePossible = false;
							}

							if (notePossible && epicNote.canBeHit)
							{
								noteHit(epicNote, strum);
								notePresses.push(epicNote);
							}
						}
					}
					else
					{
						if (!OptionsMeta.getPref("Ghost Tapping"))
						{
							noteMiss(idx, strum);
							PlayerInfo.ghostMisses++;
						}
					}

					Conductor.songPosition = prevTime;
				}

				if (babyArrow != null && babyArrow.animation.curAnim.name != 'confirm')
				{
					babyArrow.playAnim('pressed');
					babyArrow.centerOffsets();
				}
			}
			else
			{
				if (idx >= 0 && babyArrow != null)
				{
					babyArrow.playAnim('static');
					babyArrow.centerOffsets();
				}

				for (player in strum.characters)
				{
					if (player.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !keysHeld.contains(true))
					{
						if (player.animation.curAnim.name.startsWith('sing') && !player.animation.curAnim.name.endsWith('miss'))
							player.dance();
					}
				}
			}
		}
	}

	/**
		Sort through possible hit notes
		@author Shadow_Mario_
	**/
	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.step, b.step);
	}

	public function noteHit(note:Note, strum:Strum)
	{
		if (!note.wasGoodHit)
		{
			note.wasGoodHit = true;

			callFunc('goodNoteHit', [note, strum]);

			var babyArrow:BabyArrow = strum.babyArrows.members[note.index];

			if (babyArrow != null && babyArrow.animation.curAnim.name != 'confirm')
			{
				babyArrow.playAnim('confirm', true);
				babyArrow.centerOffsets();
			}

			var stringAnim:String = '';
			var section = song.sectionNotes[Std.int(curStep / 16)];

			// painful if statement
			if (section != null)
				if (section.animation != null && section.animation != '')
					stringAnim = section.animation;

			for (char in strum.characters)
			{
				if (char != null)
				{
					char.playAnim(char.singAnims[note.index] + stringAnim, true);
					Conductor.songVocals.volume = 1;
					char.holdTimer = 0;
				}
			}

			var lowestDiff:Float = Math.POSITIVE_INFINITY;
			var noteDiff:Float = Math.abs(note.step - Conductor.songPosition);
			var ratingInteger:Int = 3; // 3 is "Shit"

			if (note.mustPress && !strum.autoplay) // being hit by the player
			{
				for (i in 0...PlayerInfo.judgeTable.length)
				{
					var timingMod:Float = PlayerInfo.judgeTable[i].timingMod;
					if (noteDiff <= timingMod && (timingMod < lowestDiff))
					{
						ratingInteger = i;
						lowestDiff = timingMod;
					}
				}

				if (!note.isSustain)
				{
					if (PlayerInfo.judgeTable[ratingInteger].causesBreak)
						PlayerInfo.breaks += 1;

					if (ratingInteger > PlayerInfo.greatestJudgement)
						PlayerInfo.greatestJudgement = ratingInteger;

					PlayerInfo.increaseScore(ratingInteger);
					popUpScore(PlayerInfo.judgeTable[ratingInteger].name);

					if (PlayerInfo.judgeTable[ratingInteger].noteSplash)
						popUpSplash(note.x, note.y, note.index);

					// update scoretext
					gameUI.updateScoreText();
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
			if (PlayerInfo.combo >= 5)
				if (crowd.animOffsets.exists("sad"))
					crowd.playAnim("sad");
		}

		for (char in strum.characters)
		{
			if (char != null && char.hasMissAnims)
				char.playAnim(char.singAnims[idx] + 'miss');
		}
		FlxG.sound.play(AssetHandler.grabAsset("miss" + FlxG.random.int(1, 3), SOUND, "sounds/" + assetSkin), FlxG.random.float(0.1, 0.2));
		Conductor.songVocals.volume = 0;

		PlayerInfo.decreaseScore();
		gameUI.updateScoreText();
	}

	public function popUpScore(myRating:String = 'sick', preload:Bool = false)
	{
		var rating:FlxSprite = PlayerInfo.generateRating(assetSkin);

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

		var stringCombo:String = Std.string(PlayerInfo.combo);
		var splitCombo:Array<String> = stringCombo.split("");

		for (i in 0...splitCombo.length)
		{
			var numScore:FlxSprite = PlayerInfo.generateCombo(assetSkin);

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

	public function popUpSplash(x:Float, y:Float, index:Int)
	{
		//
		var firework = splashGroup.recycle(NoteSplash);
		firework.setupNoteSplash(x, y, index);
		firework.alpha = 1;
		splashGroup.add(firework);
	}

	public function charDancing(beat:Int)
	{
		for (strum in strumsGroup)
		{
			for (i in strum.characters)
			{
				var boppingBeat = (i.isQuickDancer ? beat % Math.round(crowdSpeed) * i.bopTimer == 0 : beat % i.bopTimer == 0);

				if (i != null && !i.animation.curAnim.name.startsWith("sing") && boppingBeat && (i.animOffsets.exists(i.defaultIdle)))
					i.dance();
			}
		}

		var boppingBeat = (crowd.isQuickDancer ? beat % Math.round(crowdSpeed) * crowd.bopTimer == 0 : beat % crowd.bopTimer == 0);
		if (crowd != null
			&& !crowd.animation.curAnim.name.startsWith("sing")
			&& boppingBeat
			&& (crowd.animOffsets.exists(crowd.defaultIdle)))
		{
			crowd.dance();
		}
	}

	override function beatHit()
	{
		charDancing(curBeat);

		FeatherTools.cameraBumpReset(curBeat, camGame, bumpSpeed, 0.015);
		FeatherTools.cameraBumpReset(curBeat, camHUD, bumpSpeed, 0.03);

		gameUI.updateIconScale();
		gameStage.stageBeatHit(curBeat, player, opponent, crowd);
		callFunc('beatHit', [curBeat]);

		super.beatHit();
	}

	override function stepHit()
	{
		Conductor.stepResync();
		gameStage.stageStepHit(curStep, player, opponent, crowd);
		callFunc('stepHit', [curStep]);
		super.stepHit();
	}

	override function sectionHit()
	{
		gameStage.stageSectionHit(curBeat, player, opponent, crowd);
		callFunc('sectionHit', [curSection]);
		super.sectionHit();
	}

	override function openSubState(SubState:flixel.FlxSubState)
	{
		callFunc('openSubState', []);
		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		isPaused = false;
		changePresence();
		callFunc('closeSubState', []);
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

		callFunc('endSong', []);

		switch (gameplayMode)
		{
			case STORY:
				// playlist conditions go here
				MusicState.switchState(new funkin.states.menus.StoryMenu());
			case FREEPLAY:
				MusicState.switchState(new funkin.states.menus.FreeplayMenu());
			case CHARTING:
				isPaused = true;
				Conductor.pauseSong();
				globalManagerPause();
				changePresence("Finished playing a song - ");
				openSubState(new funkin.substates.PauseSubstate(player.getScreenPosition().x, player.getScreenPosition().y, "charting"));
		}
	}

	override public function destroy()
	{
		Controls.keyEventTrigger.remove(keyEventTrigger);
		super.destroy();
	}

	// MODULES
	public function callFunc(key:String, args:Array<Dynamic>)
	{
		if (modules != null)
		{
			for (i in modules)
				i.call(key, args);
			if (song != null)
				callModuleLocals();
		}
	}

	public function setVar(key:String, value:Dynamic)
	{
		var allSucceed:Bool = true;
		if (modules != null)
		{
			for (i in modules)
			{
				i.set(key, value);

				if (!i.exists(key))
				{
					trace('${i.scriptFile} failed to set $key for its interpreter, continuing.');
					allSucceed = false;
					continue;
				}
			}
		}
		return allSucceed;
	}

	private function callModuleLocals()
	{
		setVar('elapsed', FlxG.elapsed);
		setVar('curBeat', curBeat);
		setVar('curStep', curStep);
		setVar('curSection', curSection);
	}
}
