package base.meta;

import flixel.FlxG;
import flixel.FlxSprite;
import funkin.states.PlayState;

enum HighscoreType
{
	CAMPAIGN;
	FREEPLAY;
}

typedef Judgement =
{
	var name:String;
	var score:Int;
	var health:Float;
	var timingMod:Float;
	var percentMod:Float;
	var noteSplash:Bool;
	var causesBreak:Bool;
	var comboReturn:String;
}

/**
	PlayerInfo handles the main "competitive" structure of the engine
	it initializes things like score counters, handles accuracy, and handles judgements
 */
class PlayerInfo
{
	public static var score:Int = 0;
	public static var misses:Int = 0;
	public static var combo:Int = 0;
	public static var breaks:Int = 0; // KE players going completely wild now
	public static var ghostMisses:Int = 0;
	public static var health:Float = 1;
	public static var deaths:Float = 0;
	public static var validScore:Bool = true;

	public static var noteRatingMod:Float;
	public static var totalNotesHit:Int;
	public static var totalMinesHit:Int;

	public static var accuracy(get, default):Float;

	static function get_accuracy():Float
		return noteRatingMod / totalNotesHit;

	public static var curComboGrade:String;
	public static var curGrade:String;

	public static var greatestJudgement:Int = 0;

	public static var scoreMap:Map<String, Int> = [];
	public static var weekScoreMap:Map<String, Int> = [];
	public static var missesMap:Map<String, Int> = [];

	public static final judgeTable:Array<Judgement> = [
		{
			name: "sick",
			score: 350,
			health: 100,
			percentMod: 100,
			timingMod: 33.33, // BASED ON FNF BASE GAME TIMING WINDOWS!!! -- https://twitter.com/kade0912/status/1511477162469113859
			noteSplash: true,
			causesBreak: false,
			comboReturn: "SFC"
		},
		{
			name: "good",
			score: 150,
			health: 50,
			percentMod: 85,
			timingMod: 91.67,
			noteSplash: false,
			causesBreak: false,
			comboReturn: "GFC"
		},
		{
			name: "bad",
			score: 50,
			health: -50,
			percentMod: 50,
			timingMod: 133.33,
			noteSplash: false,
			causesBreak: false,
			comboReturn: "FC"
		},
		{
			name: "shit",
			score: -50,
			health: -100,
			percentMod: 0,
			timingMod: 166.67,
			noteSplash: false,
			causesBreak: true,
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

	// stores how many judgements you did hit
	public static var gottenJudges:Map<String, Int> = [];

	public static function resetScore()
	{
		score = 0;
		misses = 0;
		ghostMisses = 0;
		combo = 0;
		breaks = 0;
		health = 1;
		accuracy = 0;
		validScore = true;

		totalNotesHit = 0;
		totalMinesHit = 0;
		greatestJudgement = 0;
		noteRatingMod = 0.0001;

		for (i in 0...judgeTable.length)
		{
			if (!gottenJudges.exists(judgeTable[i].name))
				gottenJudges.set(judgeTable[i].name, 0);
		}

		curComboGrade = "";
		curGrade = "N/A";
	}

	public static function returnGradePercent()
	{
		var floor = Math.floor(accuracy * 100) / 100;

		var finalPercent:String = '$floor%';
		if (curComboGrade != null && curComboGrade != '')
			finalPercent = '$floor% ~ $curComboGrade';

		return ' [$finalPercent]';
	}

	public static function updateGradePercent(id:Int)
	{
		if (accuracy <= 0)
			accuracy = 0;
		if (accuracy >= 100)
			accuracy = 100;

		PlayerInfo.totalNotesHit++;
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

		// increase gotten judges count
		gottenJudges.set(judgeTable[rating].name, gottenJudges.get(judgeTable[rating].name) + 1);

		// update combo breaks counter
		if (judgeTable[rating].causesBreak)
			breaks = misses + gottenJudges.get(judgeTable[rating].name);

		PlayerInfo.updateGradePercent(Std.int(judgeTable[rating].percentMod));

		if (health > 2)
			health = 2;
	}

	public static function decreaseScore()
	{
		score += judgeTable[3].score;
		health += 0.04 * (judgeTable[3].health) / 100;
		misses += 1;

		combo = 0;

		// update combo breaks counter
		if (judgeTable[3].causesBreak)
			breaks = misses + gottenJudges.get(judgeTable[3].name);

		PlayerInfo.updateGradePercent(Std.int(judgeTable[3].percentMod));

		if (health < 0)
			health = 0;
	}

	/**
		here's where a lot of repeated code comes into play, i will eventually clean this up
		@BeastlyGhost
	**/
	//
	public static function saveScore(song:String, score:Int, diff:Int = 0)
	{
		var songFinal = song + FeatherTools.getDifficulty(diff);

		if (scoreMap.exists(songFinal))
		{
			if (scoreMap.get(songFinal) < score)
				scoreMap.set(songFinal, score);
		}
		else
			scoreMap.set(songFinal, score);

		FlxG.save.data.songScores = scoreMap;
		FlxG.save.flush();
	}

	public static function saveWeekScore(week:String, score:Int, diff:Int = 0)
	{
		var weekFinal = week + FeatherTools.getDifficulty(diff);

		if (weekScoreMap.exists(weekFinal))
		{
			if (weekScoreMap.get(weekFinal) < score)
				weekScoreMap.set(weekFinal, score);
		}
		else
			weekScoreMap.set(weekFinal, score);

		FlxG.save.data.weekScores = weekScoreMap;
		FlxG.save.flush();
	}

	public static function saveMisses(song:String, misses:Int, diff:Int = 0)
	{
		var songFinal = song + FeatherTools.getDifficulty(diff);

		if (missesMap.exists(songFinal))
		{
			if (missesMap.get(songFinal) < misses)
				missesMap.set(songFinal, misses);
		}
		else
			missesMap.set(songFinal, misses);

		FlxG.save.data.songMisses = missesMap;
		FlxG.save.flush();
	}

	public static function getScore(song:String, diff:Int)
	{
		if (!scoreMap.exists(song + FeatherTools.getDifficulty(diff)))
			scoreMap.set(song + FeatherTools.getDifficulty(diff), 0);

		return scoreMap.get(song + FeatherTools.getDifficulty(diff));
	}

	public static function getMisses(song:String, diff:Int)
	{
		if (!missesMap.exists(song + FeatherTools.getDifficulty(diff)))
			missesMap.set(song + FeatherTools.getDifficulty(diff), 0);

		return missesMap.get(song + FeatherTools.getDifficulty(diff));
	}

	public static function getWeekScore(week:String, diff:Int)
	{
		if (!weekScoreMap.exists(week + FeatherTools.getDifficulty(diff)))
			weekScoreMap.set(week + FeatherTools.getDifficulty(diff), 0);

		return weekScoreMap.get(week + FeatherTools.getDifficulty(diff));
	}

	public static function loadHighscores()
	{
		if (FlxG.save.data.songScores != null)
			scoreMap = FlxG.save.data.songScores;
		if (FlxG.save.data.weekScores != null)
			weekScoreMap = FlxG.save.data.weekScores;
		if (FlxG.save.data.songMisses != null)
			missesMap = FlxG.save.data.songMisses;
	}
}
