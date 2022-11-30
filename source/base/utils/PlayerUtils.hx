package base.utils;

import flixel.FlxSprite;
import states.PlayState;

typedef Judgement =
{
	var name:String;
	var score:Int;
	var health:Float;
	var timingMod:Float;
	var percentMod:Float;
	var comboReturn:String;
}

/**
	PlayerUtils handles the main "competitive" structure of the engine
	it initializes things like score counters, handles accuracy, and handles judgements
 */
class PlayerUtils
{
	public static var score:Int = 0;
	public static var misses:Int = 0;
	public static var combo:Int = 0;
	public static var health:Float = 1;
	public static var deaths:Float = 0;

	public static var noteRatingMod:Float;
	public static var totalNotesHit:Int;
	public static var totalMinesHit:Int;

	public static var accuracy(get, default):Float;

	static function get_accuracy():Float
		return noteRatingMod / totalNotesHit;

	public static var curComboGrade:String;
	public static var curGrade:String;

	public static var greatestJudgement:Int = 0;
	public static var timingThreshold:Float = 0;

	public static var scoreMap:Map<String, Int> = [];
	public static var weekScoreMap:Map<String, Int> = [];
	public static var accuracyMap:Map<String, Float> = [];
	public static var missesMap:Map<String, Float> = [];

	public static final judgeTable:Array<Judgement> = [
		{
			name: "sick",
			score: 350,
			health: 100,
			percentMod: 100,
			timingMod: 33.33, // BASED ON FNF BASE GAME TIMING WINDOWS!!! -- https://twitter.com/kade0912/status/1511477162469113859
			comboReturn: "SFC"
		},
		{
			name: "good",
			score: 150,
			health: 50,
			percentMod: 85,
			timingMod: 91.67,
			comboReturn: "GFC"
		},
		{
			name: "bad",
			score: 50,
			health: -50,
			percentMod: 50,
			timingMod: 133.33,
			comboReturn: "FC"
		},
		{
			name: "shit",
			score: -50,
			health: -100,
			percentMod: 0,
			timingMod: 166.67,
			comboReturn: null
		}
	];

	public static var gradeLetters:Map<String, Int> = [
		"SS" => 100,
		"S" => 99,
		"A" => 95,
		"B" => 85,
		"C" => 70,
		"SX" => 69, // Nice
		"D" => 68,
		"F" => 50,
	];

	public static function resetScore()
	{
		score = 0;
		misses = 0;
		combo = 0;
		health = 1;
		accuracy = 0;

		totalNotesHit = 0;
		totalMinesHit = 0;
		greatestJudgement = 0;
		noteRatingMod = 0.0001;

		var greatestT:Float = 0;
		for (i in 0...judgeTable.length)
			if (judgeTable[i].timingMod > greatestT)
				greatestT = judgeTable[i].timingMod;
		timingThreshold = greatestT;

		curComboGrade = "";
		curGrade = "N/A";
	}

	public static function returnGradePercent()
	{
		var floor = Math.floor(accuracy * 100) / 100;

		var finalPercent:String = '$floor%';
		if (curComboGrade != null && curComboGrade != '')
			finalPercent = '$floor% - $curComboGrade';

		return ' [$finalPercent]';
	}

	public static function updateGradePercent(id:Int)
	{
		if (accuracy <= 0)
			accuracy = 0;
		if (accuracy >= 100)
			accuracy = 100;

		PlayerUtils.totalNotesHit++;
		noteRatingMod += (Math.max(0, id));
		updateGrade();
	}

	public static function updateGrade()
	{
		var biggestAccuracy:Float = 0;
		for (grade in gradeLetters.keys())
		{
			if (gradeLetters.get(grade) <= accuracy && gradeLetters.get(grade) >= biggestAccuracy)
			{
				biggestAccuracy = gradeLetters.get(grade);
				curGrade = grade;
			}
		}

		curComboGrade = "";
		// Update FC Display;
		if (judgeTable[greatestJudgement].comboReturn != null)
			curComboGrade = judgeTable[greatestJudgement].comboReturn;

		if (misses > 0)
			curComboGrade = (misses < 10 ? 'SDCB' : '');
	}

	public static function generateRating(skin:String = 'default')
	{
		var width:Int = (skin == "pixel" ? 60 : 346);
		var height:Int = (skin == "pixel" ? 21 : 155);

		var rating:FlxSprite = new FlxSprite();
		rating.loadGraphic(AssetHandler.grabAsset("ratings", IMAGE, "images/ui/" + skin), true, width, height);

		for (i in 0...judgeTable.length)
			rating.animation.add(judgeTable[i].name, [i]);

		rating.setGraphicSize(Std.int(rating.width * (skin == "pixel" ? PlayState.pixelAssetSize : 0.7)));
		rating.updateHitbox();

		rating.antialiasing = (skin != "pixel");

		return rating;
	}

	public static function generateCombo(skin:String = 'default')
	{
		var width:Int = (skin == "pixel" ? 12 : 108);
		var height:Int = (skin == "pixel" ? 12 : 142);

		var combo:FlxSprite = new FlxSprite();
		combo.loadGraphic(AssetHandler.grabAsset("combo_numbers", IMAGE, "images/ui/" + skin), true, width, height);

		for (i in 0...10)
			combo.animation.add('num' + i, [i]);

		combo.setGraphicSize(Std.int(combo.width * (skin == "pixel" ? PlayState.pixelAssetSize : 0.5)));
		combo.updateHitbox();

		combo.antialiasing = (skin != "pixel");

		return combo;
	}

	public static function increaseScore(rating:Int)
	{
		score += judgeTable[rating].score;
		health += 0.04 * (judgeTable[rating].health) / 100;

		if (combo < 0)
			combo = 0;
		combo += 1;

		PlayerUtils.updateGradePercent(Std.int(judgeTable[rating].percentMod));

		if (health > 2)
			health = 2;
	}

	public static function decreaseScore()
	{
		score += judgeTable[3].score;
		health += 0.06 * (judgeTable[3].health) / 100;
		misses += 1;

		combo = 0;

		PlayerUtils.updateGradePercent(Std.int(judgeTable[3].percentMod));

		if (health < 0)
			health = 0;
	}
}
