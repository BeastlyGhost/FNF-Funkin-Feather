package funkin.states;

import feather.tools.FeatherModule;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import funkin.essentials.PlayerInfo;
import funkin.essentials.song.*;
import funkin.essentials.song.MusicState;
import funkin.essentials.song.SongFormat.FeatherSong;
import funkin.objects.Character;
import funkin.objects.Stage;
import funkin.objects.ui.UI;
import funkin.objects.ui.notes.*;
import funkin.objects.ui.notes.Strum.BabyArrow;
import funkin.substates.GameOverSubstate;
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
	public static var localScripts:Array<FeatherModule> = [];

	// Song
	public static var song(default, set):FeatherSong;
	@:isVar public static var songSpeed(get, default):Float = 1; // this needs to be a (get, set) later

	public static function set_song(newSong:FeatherSong):FeatherSong
	{
		if (newSong != null && song != newSong)
		{
			// clear notes prior to storing new ones
			if (notesGroup != null)
				notesGroup.destroy();

			Conductor.stopSong();
			if (FlxG.sound.music != null && FlxG.sound.music.playing)
				FlxG.sound.music.stop();

			song = newSong;
			songSpeed = song.speed;

			Conductor.callVocals(song.name);
			Conductor.changeBPM(song.bpm);
			// Conductor.mapBPMChanges(song);

			song = ChartParser.loadChartNotes(song);

			if (ChartParser.noteList.length > 0)
			{
				noteContainer = [];
				for (i in 0...ChartParser.noteList.length)
					noteContainer.push(ChartParser.noteList[i]);
			}
		}

		return song;
	}

	public static function get_songSpeed():Float
		return FlxMath.roundDecimal(songSpeed, 2) /* / Conductor.songRate*/;

	public static var songName:String = 'test';
	public static var difficulty:Int = 0;
	public static var currentWeek:Int = 0;

	public static var songPlaylist:Array<String> = [];

	// User Interface
	public static var strumsGroup:FlxTypedGroup<Strum>;
	public static var notesGroup:Notefield;
	public static var noteContainer:Array<Note>;

	public static var ui:UI;

	public static var strumsP1:Strum;
	public static var strumsP2:Strum;

	public static var playerStrum:Strum;

	public static var assetSkin:String = 'default';

	// how big to stretch the pixel assets
	public static var pixelAssetSize:Float = 6;

	// Objects
	public static var player:Character;
	public static var opponent:Character;

	private var gameStage:Stage;

	public static var curStage:String = '';

	// Camera
	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;

	private var camFollow:FlxObject;

	private static var prevFollow:FlxObject;

	public static var cameraSpeed:Float = 1;
	public static var cameraZoom:Float = 1.05;
	public static var bumpSpeed:Float = 4;

	// Gameplay and Events
	public static var gameplayMode:GameModes;

	// Discord RPC variables
	public static var lineRPC1:String = '';
	public static var lineRPC2:String = '';

	public override function create():Void
	{
		super.create();

		main = this;

		localScripts = [];

		curStage = "";

		FlxG.mouse.visible = false;

		PlayerInfo.resetScore();

		cameraSpeed = 1 * Conductor.songRate;
		cameraZoom = 1.05;
		bumpSpeed = 4;

		// initialize main variales
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();

		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		// generate the song
		song = ChartParser.loadChartData(songName, difficulty);

		// broken for now.
		// FeatherModule.createInstance(localScripts);
		// trace(localScripts);

		gameStage = new Stage().setStage((song.stage == null ? "unknown" : song.stage));
		add(gameStage);

		opponent = new Character(false).setCharacter(gameStage.opponentPos.x, gameStage.opponentPos.y, song.opponent);
		player = new Character(true).setCharacter(gameStage.playerPos.x, gameStage.playerPos.y, song.player);

		add(opponent);
		add(player);

		strumsGroup = new FlxTypedGroup<Strum>();
		notesGroup = new Notefield();

		strumsGroup.cameras = [camHUD];
		notesGroup.cameras = [camHUD];

		var strumX:Float = (FlxG.width / 2) - 30;
		var strumWidthX:Float = (FlxG.width / 4);
		var strumY:Float = (OptionsAPI.getPref("Downscroll") ? FlxG.height - 170 : 25);

		strumsP1 = new Strum(strumX + (OptionsAPI.getPref("Center Notes") ? 0 : strumWidthX), strumY, [player], false, OptionsAPI.getPref("Downscroll"));
		strumsP2 = new Strum(strumX - strumWidthX, strumY, [opponent], true, OptionsAPI.getPref("Downscroll"));

		strumsGroup.add(strumsP1);
		strumsGroup.add(strumsP2);

		playerStrum = strumsP1;

		if (OptionsAPI.getPref("Hide Opponent Notes") || OptionsAPI.getPref("Center Notes"))
			strumsP2.visible = false;

		add(strumsGroup);
		add(notesGroup);

		ui = new UI();
		ui.cameras = [camHUD];
		add(ui);

		camFollow = new FlxObject(0, 0, 1, 1);
		if (prevFollow != null)
		{
			camFollow = prevFollow;
			prevFollow = null;
		}

		add(camFollow);

		FlxG.camera.zoom = cameraZoom;

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		Controls.onKeyPressed.add(onKeyPressed);
		Controls.onKeyReleased.add(onKeyReleased);

		songCutscene();
		changePresence();

		callFunc('postCreate', []);
	}

	public static function changePresence(addString:String = ''):Void
	{
		var mode:String = 'Freeplay';

		switch (gameplayMode)
		{
			case STORY:
				mode = "Story Mode";
			case FREEPLAY | CHARTING:
				mode = "Freeplay";
		}

		var stringDiff = FeatherUtils.getDifficulty(difficulty);

		lineRPC2 = '${PlumaStrings.toTitle(song.name)} [${stringDiff.replace('-', '').toUpperCase()}]';

		DiscordRPC.update(addString + lineRPC1, mode + ' - ' + lineRPC2);
	}

	public var canPause:Bool = false;
	public var isPaused:Bool = false;
	public var countdownStarted:Bool = false;
	public var countdownEnded:Bool = false;
	public var skipCountdown:Bool = false;

	public function songCutscene():Void
	{
		if (!isEndingSong)
		{
			for (babyStrum in strumsGroup)
			{
				babyStrum.babyArrows.forEachAlive(function(babyArrow:BabyArrow)
				{
					babyArrow.alpha = 0;
				});
			}

			Conductor.songPosition = -(Conductor.crochet * 16);
		}

		gameStage.callFunc('songCutscene' + (isEndingSong ? 'End' : ''), []);

		isStartingSong = true;
		startCountdown();
	}

	var posCount:Int = 0;
	var posSong:Int = 4;

	public function startCountdown():Void
	{
		countdownStarted = true;
		canPause = true;

		// cache ratings
		popUpScore('sick', true, true);

		if (countdownEnded && !isPaused && !hasDied && skipCountdown)
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

		cameraPanChar(1);

		for (graphic in introGraphicNames)
			introGraphics.push(AssetHelper.grabAsset(graphic, IMAGE, 'images/ui/$assetSkin'));

		for (sound in introSoundNames)
			introSounds.push(AssetHelper.grabAsset(sound, SOUND, 'sounds/$assetSkin'));

		new FlxTimer().start(Conductor.crochet / 1000 / Conductor.songRate, function(tmr:FlxTimer)
		{
			if (introGraphics[posCount] != null)
			{
				var introSprite = new FlxSprite().loadGraphic(introGraphics[posCount]);
				introSprite.scrollFactor.set();
				introSprite.updateHitbox();
				introSprite.screenCenter();
				add(introSprite);

				if (assetSkin == "pixel")
				{
					introSprite.setGraphicSize(Std.int(introSprite.width * pixelAssetSize));
					introSprite.antialiasing = false;
				}

				FlxTween.tween(introSprite, {y: introSprite.y += 50, alpha: 0}, Conductor.crochet / 1000 / Conductor.songRate, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						introSprite.kill();
					}
				});
			}

			if (introSounds[posCount] != null)
				FlxG.sound.play(introSounds[posCount]);

			// bop with countdown;
			charDancing(curBeat);
			gameStage.stageCountdownTick(curBeat);

			Conductor.songPosition = -(Conductor.crochet * posSong);

			posSong -= 1;
			posCount += 1;

			callFunc('countdownTick', [posCount]);

			if (posCount == 4)
			{
				ui.showInfoCard();
				countdownEnded = true;
			}
		}, 5);
	}

	function startSong():Void
	{
		callFunc('startSong', []);

		if (isStartingSong && !isEndingSong)
		{
			Conductor.playSong(song.name, Conductor.songMusic.playing);
			isStartingSong = false;
		}
	}

	public override function update(elapsed:Float):Void
	{
		callFunc('update', [elapsed]);

		super.update(elapsed);

		gameStage.stageUpdate(elapsed);

		if (!isPaused && !hasDied && !isEndingSong)
		{
			if (gameplayMode != STORY)
			{
				if (FlxG.keys.justPressed.SIX)
				{
					PlayerInfo.validScore = false;
					playerStrum.autoplay = !playerStrum.autoplay;
					ui.autoPlayText.visible = playerStrum.autoplay;
					ui.autoPlaySine = 1;
				}

				if (FlxG.keys.justPressed.SEVEN)
				{
					PlayerInfo.validScore = false;
					gameplayMode = CHARTING;
					Conductor.pauseSong();
					MusicState.switchState(new funkin.states.editors.ChartEditor());
				}

				if (FlxG.keys.justPressed.EIGHT)
				{
					var char:Character = (FlxG.keys.pressed.SHIFT ? player : opponent);

					Conductor.pauseSong();
					MusicState.switchState(new funkin.states.editors.OffsetEditor(char.name, char.player));
				}
			}

			Conductor.songPosition += elapsed * 1000;
			if (Conductor.songPosition >= 0 && !Conductor.songMusic.playing && !isStartingSong)
				startSong();

			if (Conductor.songPosition > Conductor.lastSongPos)
				Conductor.lastSongPos = Conductor.songPosition;

			if (song != null)
			{
				if (song.sectionNotes != null && song.sectionNotes[curSection] != null)
					cameraPanChar();
			}
		}

		FeatherUtils.cameraBumpingZooms(camGame, cameraZoom, cameraSpeed);
		FeatherUtils.cameraBumpingZooms(camHUD, 1);

		playerDeathCheck();

		if (Controls.isJustPressed("pause") && canPause)
		{
			pauseGame();
			changePresence("Paused - ");
			openSubState(new funkin.substates.PauseSubstate(player.getScreenPosition().x, player.getScreenPosition().y, "default"));
		}

		while (noteContainer[0] != null)
		{
			var spicyNote:Note = noteContainer[0];

			if (!spicyNote.noteData.mustPress)
			{
				spicyNote.visible = !OptionsAPI.getPref("Hide Opponent Notes");
				if (OptionsAPI.getPref("Center Notes"))
				{
					spicyNote.alpha = 0.3;
					for (i in 0...strumsP1.babyArrows.members.length)
						spicyNote.x = strumsP1.babyArrows.members[i].x;
				}
			}

			if (spicyNote.step - Conductor.songPosition > 2000)
				break;

			notesGroup.add(spicyNote);
			noteContainer.shift();
		}

		if (song != null)
		{
			if (countdownStarted)
			{
				for (babyStrum in strumsGroup)
				{
					babyStrum.babyArrows.forEachAlive(function(babyArrow:BabyArrow)
					{
						if (babyStrum.autoplay && babyArrow.animation.curAnim.name == 'confirm' && babyArrow.animation.curAnim.finished)
							babyArrow.playAnim('static');
					});
				}

				notesGroup.forEachAlive(function(note:Note)
				{
					var babyStrum:Strum = note.noteData.mustPress ? playerStrum : strumsP2;

					if (!babyStrum.autoplay && keysHeld.contains(true) && keysHeld[note.index] && note.noteData.canBeHit && note.noteData.mustPress
						&& note.isSustain && !note.noteData.tooLate)
						noteHit(note, babyStrum);

					note.speed = songSpeed;

					notesGroup.updatePosition(note, babyStrum);

					if (babyStrum.autoplay)
					{
						// todo: accurate autoplay?
						if (note.step < Conductor.songPosition)
							noteHit(note, babyStrum);
					}

					var killRangeReached:Bool = babyStrum.downscroll ? note.y > FlxG.height : note.y < -note.height;

					// kill offscreen notes and cause misses if needed
					if (Conductor.songPosition > note.judgeData.missOffset + note.step)
					{
						note.active = false;
						note.visible = false;

						if (killRangeReached)
							notesGroup.removeNote(note, noteContainer);

						if (note.noteData.mustPress && !note.noteData.tooLate && !note.noteData.wasGoodHit)
						{
							if (!note.isSustain)
							{
								note.noteData.tooLate = true;

								// declare children as late
								for (hold in note.children)
									hold.noteData.tooLate = true;

								// ignore misses if it's a mine or ignore note
								if (note.typeData.ignoreNote || note.typeData.isMine)
									return;

								noteMiss(note.index, babyStrum);
							}
						}
					}
				});
			}
			else
			{
				// prevent hits if the countdown was not active
				notesGroup.forEachAlive(function(note:Note)
				{
					note.noteData.canBeHit = false;
					note.noteData.wasGoodHit = false;
				});
			}
		}

		callFunc('postUpdate', [elapsed]);
	}

	private var hasDied:Bool = false;

	public function playerDeathCheck():Bool
	{
		if (PlayerInfo.stats.health <= 0 && !hasDied)
		{
			pauseGame();
			Conductor.pauseSong(); // *beep boops stop*
			PlayerInfo.stats.deaths += 1;
			hasDied = true;

			callFunc('onDeath', []);

			persistentUpdate = false;
			persistentDraw = false;

			FSound.playSound("fnf_loss_sfx", 'sounds/$assetSkin');

			var playerPos:FlxPoint = player.getScreenPosition();

			changePresence("Dead - ");
			openSubState(new GameOverSubstate(playerPos.x, playerPos.y));
			return true;
		}
		return false;
	}

	public function onKeyPressed(key:Int, action:String, isGamepad:Bool):Void
	{
		if (isPaused || isEndingSong || playerStrum.autoplay)
			return;

		if (action != null && BabyArrow.actions.contains(action))
			inputSystem(BabyArrow.actions.indexOf(action), true);
		callFunc('onKeyPress', [key, action, isGamepad]);
	}

	public function cameraPanChar(?force:Int):Void
	{
		var index:Int = (force != null ? force : song.sectionNotes[curSection].hitIndex);
		var char:Character = (index == 1 ? player : opponent);
		var midpoint:FlxPoint = char.getMidpoint();

		camFollow.setPosition(midpoint.x + char.camOffset.x + (index == 1 ? -100 : 100), midpoint.y - 100 + char.camOffset.y);
	}

	public function onKeyReleased(key:Int, action:String, isGamepad:Bool):Void
	{
		if (isPaused || isEndingSong || playerStrum.autoplay)
			return;

		if (action != null && BabyArrow.actions.contains(action))
			inputSystem(BabyArrow.actions.indexOf(action), false);
		callFunc('onKeyRelease', [key, action, isGamepad]);
	}

	var keysHeld:Array<Bool> = [];

	public function inputSystem(idx:Int, pressed:Bool):Void
	{
		keysHeld[idx] = pressed;

		// shortening
		var babyArrow:BabyArrow = playerStrum.babyArrows.members[idx];

		if (pressed)
		{
			if (song != null && countdownStarted)
			{
				var noteList:Array<Note> = [];
				var notePresses:Array<Note> = [];

				notesGroup.forEachAlive(function(note:Note)
				{
					if (note.index == idx && note.noteData.mustPress && note.noteData.canBeHit && !note.isSustain && !note.noteData.tooLate
						&& !note.noteData.wasGoodHit)
						noteList.push(note);
				});
				noteList.sort(sortHitNotes);

				if (noteList.length > 0)
				{
					var notePossible:Bool = true; // usually, yeah, it should be possible to hit a note

					for (epicNote in noteList)
					{
						for (troubleNote in notePresses)
							if (Math.abs(epicNote.step - troubleNote.step) > 10)
								notePossible = false;

						if (notePossible && epicNote.noteData.canBeHit)
						{
							noteHit(epicNote, playerStrum);
							notePresses.push(epicNote);
						}
					}
				}
				else
				{
					if (!OptionsAPI.getPref("Ghost Tapping"))
						noteMiss(idx, playerStrum);
					else
						PlayerInfo.stats.ghostMisses++;
				}
			}

			if (babyArrow != null && babyArrow.animation.curAnim.name != 'confirm')
				babyArrow.playAnim('pressed', true);
		}
		else
		{
			if (idx >= 0 && babyArrow != null)
				babyArrow.playAnim('static');

			for (player in playerStrum.characters)
			{
				if (player.timers.hold > Conductor.stepCrochet * (0.001 / Conductor.songRate) * player.timers.sing && !keysHeld.contains(true))
					if (player.animation.curAnim.name.startsWith('sing') && !player.animation.curAnim.name.endsWith('miss'))
						player.dance();
			}
		}
	}

	/**
		Sort through possible hit notes
		@author Shadow_Mario_
	**/
	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.typeData.lowPriority && !b.typeData.lowPriority)
			return 1;
		else if (!a.typeData.lowPriority && b.typeData.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.step, b.step);
	}

	public function noteHit(note:Note, babyStrum:Strum):Void
	{
		if (!note.noteData.wasGoodHit)
		{
			note.noteData.wasGoodHit = true;

			var babyArrow:BabyArrow = babyStrum.babyArrows.members[note.index];

			callFunc('goodNoteHit', [note, babyStrum]);

			if (babyArrow != null)
			{
				if (OptionsAPI.getPref("User Interface Style") == "Vanilla")
					babyArrow.glowsOnHit = note.noteData.mustPress;

				if (babyArrow.glowsOnHit)
					babyArrow.playAnim('confirm', true);
			}

			for (char in babyStrum.characters)
			{
				charPlayAnim(char, 'sing' + BabyArrow.actions[note.index].toUpperCase());
				Conductor.songVocals.volume = 1;
			}

			var lowestDiff:Float = Math.POSITIVE_INFINITY;
			var noteDiff:Float = Math.abs(note.step - Conductor.songPosition);
			var ratingInteger:Int = 3; // 3 is "Shit"

			if (note.noteData.mustPress && !babyStrum.autoplay) // being hit by the player
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
						PlayerInfo.stats.breaks += 1;

					if (ratingInteger > PlayerInfo.greatestJudgement)
						PlayerInfo.greatestJudgement = ratingInteger;

					PlayerInfo.increaseScore(ratingInteger);

					// update scoretext
					ui.updateScoreText(OptionsAPI.getPref("Score Bopping"));
				}
			}

			if (!note.isSustain)
			{
				if (note.noteData.mustPress)
				{
					if (PlayerInfo.judgeTable[ratingInteger].noteSplash || note.typeData.doSplash || babyStrum.autoplay)
						babyStrum.popUpSplash(note.index);
					popUpScore(PlayerInfo.judgeTable[babyStrum.autoplay ? 0 : ratingInteger].name, !babyStrum.autoplay);
				}

				notesGroup.removeNote(note, noteContainer);
			}
		}
	}

	public function noteMiss(idx:Int, babyStrum:Strum):Void
	{
		if (babyStrum.autoplay)
			return;

		for (char in babyStrum.characters)
			if (char.hasMissAnims)
				charPlayAnim(char, 'sing' + BabyArrow.actions[idx].toUpperCase() + 'miss');

		FSound.playSound("miss" + FlxG.random.int(1, 3), 'sounds/$assetSkin', false, FlxG.random.float(0.1, 0.2));
		Conductor.songVocals.volume = 0;

		PlayerInfo.decreaseScore();
		ui.updateScoreText(false);
	}

	public function popUpScore(myRating:String = 'sick', combo:Bool = true, preload:Bool = false):Void
	{
		var rating:FlxSprite = FunkinAssets.generateRating(assetSkin);

		rating.screenCenter();
		rating.x = (FlxG.width * 0.55) - 40;
		rating.y -= 60;
		rating.acceleration.y = 550 * Conductor.songRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * Conductor.songRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * Conductor.songRate;
		add(rating);

		if (preload)
			rating.alpha = 0.000001;

		rating.animation.play(myRating);

		FlxTween.tween(rating, {alpha: 0}, 0.2 / Conductor.songRate, {
			onComplete: function(t:FlxTween)
			{
				rating.kill();
			},
			startDelay: Conductor.crochet * 0.001
		});

		if (combo)
		{
			var stringCombo:String = Std.string(PlayerInfo.stats.combo);
			var splitCombo:Array<String> = stringCombo.split("");

			for (i in 0...splitCombo.length)
			{
				var numScore:FlxSprite = FunkinAssets.generateCombo(assetSkin);

				numScore.alpha = 1;
				numScore.screenCenter();
				numScore.x += (43 * i) + 20;
				numScore.y += 60;

				numScore.acceleration.y = FlxG.random.int(200, 300) * Conductor.songRate;
				numScore.velocity.y = -FlxG.random.int(140, 160) * Conductor.songRate;
				numScore.velocity.x = FlxG.random.float(-5, 5) * Conductor.songRate;
				add(numScore);

				if (preload)
					numScore.alpha = 0.000001;

				numScore.animation.play("num" + splitCombo[i]);

				FlxTween.tween(numScore, {alpha: 0}, 0.2 / Conductor.songRate, {
					onComplete: function(t:FlxTween)
					{
						numScore.kill();
					},
					startDelay: Conductor.crochet * 0.002
				});
			}
		}
	}

	public function charPlayAnim(char:Character, stringSect:String = 'singDOWN'):Void
	{
		var sectSection:String = null;
		var section = song.sectionNotes[curSection];

		// painful if statement
		if (section != null)
			if (section.animation != null && section.animation != '')
				sectSection = section.animation;

		if (char != null)
		{
			var animToPlay:String = stringSect + (sectSection != null ? sectSection : '');
			char.playAnim(animToPlay, true);
		}
	}

	public function charDancing(beat:Int):Void
	{
		for (babyStrum in strumsGroup)
		{
			for (i in babyStrum.characters)
			{
				if (i != null && (i.animation.getByName('idle') != null || i.animation.getByName('danceRight') != null))
				{
					var timerBop:Float = (i.timers.headBop != null ? i.timers.headBop : 2);
					var boppingBeat = (i.isQuickDancer ? beat % timerBop == 0 : beat % timerBop == 0);
					if (!i.animation.curAnim.name.startsWith("sing") && boppingBeat)
						i.dance();
				}
			}
		}
	}

	override function beatHit():Void
	{
		super.beatHit();

		charDancing(curBeat);

		if (!OptionsAPI.getPref("Reduce Motion"))
		{
			FeatherUtils.cameraBumpReset(curBeat, camGame, bumpSpeed, 0.015);
			FeatherUtils.cameraBumpReset(curBeat, camHUD, bumpSpeed, 0.03);
		}

		ui.beatHit(curBeat);
		gameStage.stageBeatHit(curBeat);
		callFunc('beatHit', [curBeat]);
	}

	override function stepHit():Void
	{
		super.stepHit();

		Conductor.stepResync();
		gameStage.stageStepHit(curStep);
		callFunc('stepHit', [curStep]);
	}

	override function sectionHit():Void
	{
		super.sectionHit();

		gameStage.stageSectionHit(curSection);
		callFunc('sectionHit', [curSection]);
	}

	override function openSubState(SubState:flixel.FlxSubState):Void
	{
		Conductor.pauseSong();

		callFunc('openSubState', []);
		super.openSubState(SubState);
	}

	override function closeSubState():Void
	{
		isPaused = false;
		changePresence();
		callFunc('closeSubState', []);
		super.closeSubState();
	}

	public function pauseGame():Void
	{
		isPaused = true;
		Conductor.pauseSong();

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

	override function endSong():Void
	{
		super.endSong();

		callFunc('endSong', []);

		isEndingSong = true;
		canPause = false;

		Conductor.songPosition = Conductor.songMusic.length;
		Conductor.pauseSong();

		var dataSave:SaveScoreData = {
			score: PlayerInfo.stats.score,
			misses: PlayerInfo.stats.misses,
			accuracy: PlayerInfo.stats.accuracy
		};

		switch (gameplayMode)
		{
			case STORY:
				// playlist conditions go here
				if (PlayerInfo.validScore)
					PlayerInfo.saveInfo(song.name, difficulty, dataSave, gameplayMode);
				MusicState.switchState(new funkin.states.menus.StoryMenu());
			case FREEPLAY:
				if (PlayerInfo.validScore)
					PlayerInfo.saveInfo(song.name, difficulty, dataSave, gameplayMode);
				MusicState.switchState(new funkin.states.menus.FreeplayMenu());
			case CHARTING:
				pauseGame();
				changePresence("Finished playing a song - ");
				openSubState(new funkin.substates.PauseSubstate(player.getScreenPosition().x, player.getScreenPosition().y, "charting"));
		}

		AssetGroup.activeGroup = null;
	}

	public override function destroy():Void
	{
		Controls.onKeyPressed.remove(onKeyPressed);
		Controls.onKeyReleased.remove(onKeyReleased);
		super.destroy();
	}

	// SCRIPTS
	public function callFunc(key:String, args:Array<Dynamic>):Void
	{
		if (localScripts != null)
		{
			for (i in localScripts)
				i.call(key, args);
			if (song != null)
				callModuleLocals();
		}
	}

	public function setVar(key:String, value:Dynamic):Bool
	{
		var allSucceed:Bool = true;
		if (localScripts != null)
		{
			for (i in localScripts)
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

	private function callModuleLocals():Void
	{
		setVar('elapsed', FlxG.elapsed);
		setVar('curBeat', curBeat);
		setVar('curStep', curStep);
		setVar('curSection', curSection);
	}
}
