package funkin.objects.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxTimer;
import funkin.essentials.PlayerInfo;
import funkin.essentials.song.Conductor;
import funkin.states.PlayState;

/**
	User Interface class so we don't have to create it on PlayState,
	get as expressive as you can with this, create your own UI if you wish!
**/
class UI extends FlxSpriteGroup
{
	public var scoreText:FlxText;
	public var autoPlayText:FlxText;
	public var autoPlaySine:Float = 0;

	public var healthBG:FlxSprite;
	public var healthBar:FlxBar;

	public var iconP1:Icon;
	public var iconP2:Icon;

	public var uiStyle:String = OptionsAPI.getPref("User Interface Style");

	public function new():Void
	{
		super();

		healthBG = new FlxSprite(0, PlayState.strumsP1.downscroll ? FlxG.height * 0.1 : FlxG.height * 0.89);
		healthBG.loadGraphic(AssetHelper.grabAsset("default/healthBar", IMAGE, "images/ui"));
		healthBG.screenCenter(X);
		healthBG.scrollFactor.set();
		add(healthBG);

		healthBar = new FlxBar(healthBG.x + 4, healthBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBG.width - 8), Std.int(healthBG.height - 8));
		healthBar.scrollFactor.set();
		add(healthBar);

		iconP1 = new Icon('placeholder', true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new Icon('placeholder', false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreText = new UIText(healthBG.x + healthBG.width - 190, healthBG.y + 30, 0);
		add(scoreText);

		autoPlayText = new UIText(0, PlayState.playerStrum.downscroll ? FlxG.height - 80 : 80, FlxG.width - 800, '[AUTOPLAY]\n');
		autoPlayText.visible = PlayState.playerStrum.autoplay;
		autoPlayText.alignment = CENTER;
		autoPlayText.screenCenter(X);
		autoPlayText.size = 32;

		// repositioning for it to not be covered by the receptors
		if (OptionsAPI.getPref('Center Notes'))
		{
			if (PlayState.playerStrum.downscroll)
				autoPlayText.y = autoPlayText.y - 125;
			else
				autoPlayText.y = autoPlayText.y + 125;
		}

		add(autoPlayText);

		updateScoreText();
		updateHealthBar();
	}

	override function update(elapsed:Float):Void
	{
		healthBar.percent = (PlayerInfo.stats.health * 50);

		// attach to healthbar
		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		iconP1.updateFrame(healthBar.percent);
		iconP2.updateFrame(100 - healthBar.percent);

		if (autoPlayText.visible)
		{
			autoPlaySine += 180 * (elapsed / 4);
			autoPlayText.alpha = 1 - Math.sin((Math.PI * autoPlaySine) / 80);
		}

		super.update(elapsed);
	}

	// for reference: https://en.wikipedia.org/wiki/Template:%E2%80%A2
	public static var separator:String = " • ";

	// so you can change it separately
	public static var separatorFC:String = " • ";

	public function updateScoreText():Void
	{
		var tempScore:String = '';
		var centerText:Bool = false;

		switch (uiStyle)
		{
			case "Feather":
				tempScore = "Score: " + PlayerInfo.stats.score;
				tempScore += separator + "Misses: " + PlayerInfo.stats.misses;
				tempScore += separator + "Grade: " + PlayerInfo.curGrade + PlayerInfo.returnGradePercent();
				centerText = true;
			default:
				tempScore = "Score: " + PlayerInfo.stats.score;
		}

		scoreText.text = tempScore;

		if (centerText)
			scoreText.screenCenter(X);

		PlayState.lineRPC1 = scoreText.text;
		PlayState.changePresence();
	}

	public function updateHealthBar():Void
	{
		var colorA:Null<Int> = (PlayState.opponent.healthColor != null ? PlayState.opponent.healthColor : 0xFFFF0000);
		var colorB:Null<Int> = (PlayState.player.healthColor != null ? PlayState.player.healthColor : 0xFF66FF33);

		healthBar.createFilledBar(colorA, colorB);
		healthBar.scrollFactor.set();
		healthBar.updateBar();
	}

	public function beatHit(curBeat:Int):Void
	{
		//
		if (!OptionsAPI.getPref("Reduce Motion"))
		{
			iconP1.doBops(60 / Conductor.bpm);
			iconP2.doBops(60 / Conductor.bpm);
		}
	}

	public function showInfoCard():Void
	{
		if (!OptionsAPI.getPref("Show Info Card"))
			return;

		var blackBy:FlxSprite, byText:FlxText;
		blackBy = new FlxSprite(0).loadGraphic(AssetHelper.grabAsset('default/infobox', IMAGE, 'images/ui'));
		blackBy.screenCenter();
		blackBy.x -= FlxG.width;
		blackBy.y = FlxG.height - 120;
		blackBy.alpha = 0.7;

		byText = new FlxText(0, 0, 425);
		byText.setFormat(AssetHelper.grabAsset("vcr", FONT, "data/fonts"), 28, 0xFFFFFFFF, CENTER);
		byText.screenCenter();
		byText.x -= FlxG.width;
		byText.y = FlxG.height - 80.5;
		byText.text = FeatherTools.formatSong(PlayState.song.name);
		byText.text += '\n By: ${PlayState.song.author}';

		blackBy.setGraphicSize(Std.int(byText.width - 20), Std.int(byText.height + 105));
		blackBy.updateHitbox();
		add(blackBy);
		add(byText);
		FlxTween.tween(blackBy, {x: 0}, 3, {ease: FlxEase.expoInOut});
		FlxTween.tween(byText, {x: -40}, 3, {ease: FlxEase.expoInOut});
		new FlxTimer().start(4.75, function(tmr:FlxTimer)
		{
			FlxTween.tween(blackBy, {x: -700}, 1.6, {
				ease: FlxEase.expoInOut,
				onComplete: function(twn:FlxTween)
				{
					remove(blackBy);
					blackBy.kill();
					blackBy.destroy();
				}
			});
			FlxTween.tween(byText, {x: -650}, 1.6, {
				ease: FlxEase.expoInOut,
				onComplete: function(twn:FlxTween)
				{
					remove(byText);
					byText.kill();
					byText.destroy();
				}
			});
		});
	}
}
