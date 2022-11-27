package objects.ui;

import base.utils.ScoreUtils;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

class UI extends FlxSpriteGroup
{
	public var scoreBar:FlxText;
	public var tempVersionTxt:FlxText; // "temp" means i'm probably removing this as a whole later lol

	public var healthBG:FlxSprite;
	public var healthBar:FlxBar;

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

		scoreBar = new FlxText(healthBG.x + healthBG.width - 190, healthBG.y + 30, 0, '', 20);
		scoreBar.setFormat(AssetHandler.grabAsset("vcr", FONT, "data/fonts"), 20, FlxColor.WHITE, RIGHT, SHADOW, FlxColor.BLACK);
		scoreBar.shadowOffset.set(3, 3);
		scoreBar.scrollFactor.set();
		add(scoreBar);

		tempVersionTxt = new FlxText(0, FlxG.height - 30, 0, 'Feather ${Main.game.version}', 20);
		tempVersionTxt.setFormat(AssetHandler.grabAsset("vcr", FONT, "data/fonts"), 20, FlxColor.WHITE, RIGHT, SHADOW, FlxColor.BLACK);
		tempVersionTxt.shadowOffset.set(3, 3);
		tempVersionTxt.scrollFactor.set();
		add(tempVersionTxt);

		updateScoreBar();
		updateHealthBar();
	}

	override function update(elapsed:Float)
	{
		healthBar.percent = (ScoreUtils.health * 50);

		super.update(elapsed);
	}

	public static var separator:String = " ~ ";

	public function updateScoreBar()
	{
		var tempScore:String;

		tempScore = "Score: " + ScoreUtils.score;
		tempScore += separator + "Misses: " + ScoreUtils.misses;
		tempScore += separator + "Grade: " + ScoreUtils.curGrade + ScoreUtils.returnGradePercent();

		scoreBar.text = tempScore;
		scoreBar.screenCenter(X);
	}

	public function updateHealthBar()
	{
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		healthBar.updateBar();
		healthBar.scrollFactor.set();
	}
}
