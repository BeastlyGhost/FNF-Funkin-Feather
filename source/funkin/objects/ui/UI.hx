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
import funkin.backend.data.PlayerInfo;
import funkin.song.Conductor;
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

		healthBG = new FlxSprite(0, PlayState.strumsP1.downscroll ? FlxG.height * 0.1 : FlxG.height * (uiStyle.contains("Feather") ? 0.92 : 0.89));
		healthBG.loadGraphic(AssetHandler.grabAsset("base/healthBar", IMAGE, "images/ui"));
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

		scoreText = new FlxText(healthBG.x + healthBG.width - 190, healthBG.y + 30, 0, '', 20);
		scoreText.setFormat(AssetHandler.grabAsset((uiStyle.contains("Feather") ? "muff-bold" : "vcr"), FONT, "data/fonts"), 20, 0xFFFFFFFF, CENTER, SHADOW,
			0xFF000000);
		scoreText.shadowOffset.set(2, 2);
		scoreText.scrollFactor.set();
		add(scoreText);

		autoPlayText = new FlxText(-5, PlayState.playerStrum.downscroll ? FlxG.height - 80 : 80, FlxG.width - 800, '[AUTOPLAY]\n', 32);
		autoPlayText.setFormat(AssetHandler.grabAsset((uiStyle.contains("Feather") ? "muff-bold" : "vcr"), FONT, "data/fonts"), 32, 0xFFFFFFFF, CENTER,
			SHADOW, 0xFF000000);
		autoPlayText.shadowOffset.set(2, 2);
		autoPlayText.screenCenter(X);
		autoPlayText.visible = PlayState.playerStrum.autoplay;

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
		var tempScore:String;

		tempScore = "Score: " + PlayerInfo.stats.score;

		if (uiStyle.contains("Detailed"))
		{
			tempScore += separator + "Misses: " + PlayerInfo.stats.misses;
			tempScore += separator + "Grade: " + PlayerInfo.curGrade + PlayerInfo.returnGradePercent();
		}

		scoreText.text = tempScore;
		scoreText.screenCenter(X);

		PlayState.lineRPC1 = scoreText.text;
		PlayState.changePresence();
	}

	public function updateHealthBar():Void
	{
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		healthBar.updateBar();
		healthBar.scrollFactor.set();
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
		blackBy = new FlxSprite(0).loadGraphic(AssetHandler.grabAsset('base/infobox', IMAGE, 'images/ui'));
		blackBy.screenCenter();
		blackBy.x -= FlxG.width;
		blackBy.y = FlxG.height - 120;
		blackBy.alpha = 0.7;

		byText = new FlxText(0, 0, 425);
		byText.setFormat(AssetHandler.grabAsset("vcr", FONT, "data/fonts"), 28, 0xFFFFFFFF, CENTER);
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
