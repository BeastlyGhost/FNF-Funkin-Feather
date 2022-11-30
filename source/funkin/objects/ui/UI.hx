package funkin.objects.ui;

import base.utils.PlayerUtils;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.states.PlayState;

/**
	User Interface class so we don't have to create it on PlayState,
	get as expressive as you can with this, create your own UI if you wish!
**/
class UI extends FlxSpriteGroup
{
	public var scoreBar:FlxText;

	public var healthBG:FlxSprite;
	public var healthBar:FlxBar;

	public var iconP1:Icon;
	public var iconP2:Icon;

	public function new()
	{
		super();

		healthBG = new FlxSprite(0, FlxG.height * 0.89);
		healthBG.loadGraphic(AssetHandler.grabAsset("default/healthBar", IMAGE, "images/ui"));
		healthBG.screenCenter(X);
		healthBG.scrollFactor.set();
		add(healthBG);

		healthBar = new FlxBar(healthBG.x + 4, healthBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBG.width - 8), Std.int(healthBG.height - 8));
		healthBar.scrollFactor.set();
		add(healthBar);

		iconP1 = new Icon('bf', true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new Icon('bf', false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreBar = new FlxText(healthBG.x + healthBG.width - 190, healthBG.y + 30, 0, '', 20);
		scoreBar.setFormat(AssetHandler.grabAsset("vcr", FONT, "data/fonts"), 20, FlxColor.WHITE, CENTER, SHADOW, FlxColor.BLACK);
		scoreBar.shadowOffset.set(2, 2);
		scoreBar.scrollFactor.set();
		add(scoreBar);

		updateScoreBar();
		updateHealthBar();
	}

	override function update(elapsed:Float)
	{
		healthBar.percent = (PlayerUtils.health * 50);

		// attach to health
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.85)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.85)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		iconP1.updateFrame(healthBar.percent);
		iconP2.updateFrame(100 - healthBar.percent);

		super.update(elapsed);
	}

	public static var separator:String = " ~ ";

	public function updateScoreBar()
	{
		var tempScore:String;

		tempScore = "Score: " + PlayerUtils.score;

		if (OptionsMeta.getPref("Show Grades"))
		{
			tempScore += separator + "Misses: " + PlayerUtils.misses;
			tempScore += separator + "Grade: " + PlayerUtils.curGrade + PlayerUtils.returnGradePercent();
		}

		scoreBar.text = tempScore;
		scoreBar.screenCenter(X);

		PlayState.lineRPC1 = scoreBar.text;
		PlayState.changePresence();
	}

	public function updateHealthBar()
	{
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		healthBar.updateBar();
		healthBar.scrollFactor.set();
	}

	public function updateIconScale()
	{
		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP1.updateHitbox();

		iconP2.setGraphicSize(Std.int(iconP2.width + 30));
		iconP2.updateHitbox();
	}

	public function showInfoCard()
	{
		var blackBy, byText;
		blackBy = new FlxSprite().loadGraphic(AssetHandler.grabAsset('infobox', IMAGE, 'images/ui/default'));
		blackBy.screenCenter();
		blackBy.x -= FlxG.width;
		blackBy.alpha = 0.7;
		blackBy.y = FlxG.height - 120;
		byText = new FlxText(0, 0, 425);
		byText.setFormat(AssetHandler.grabAsset("vcr", FONT, "data/fonts"), 28, FlxColor.WHITE, CENTER);
		// byText.borderSize *= 1.25;
		// byText.borderQuality *= 1.25;
		byText.screenCenter();
		byText.x -= FlxG.width;
		byText.y = FlxG.height - 80.5;
		byText.text = FeatherTools.coolSongFormatter(PlayState.song.name);
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
