package funkin.essentials;

import flixel.FlxG;
import funkin.states.PlayState;

typedef Judgement = {
	var name:String;
	var score:Int;
	var health:Float;
	var timingMod:Float;
	var percentMod:Float;
	var noteSplash:Bool;
	var causesBreak:Bool;
	var comboReturn:String;
}

typedef SaveScoreData = {
	var score:Int;
	var misses:Int;
	var accuracy:Float;
	var ?gameplayMode:GameModes;
	var ?difficulty:String;
}

/**
	PlayerInfo handles the main "competitive" structure of the engine
	it initializes things like score counters, handles accuracy, and handles judgements
 */
class PlayerInfo {
	public static var stats:Dynamic = {
		score: 0,
		misses: 0,
		combo: 0,
		breaks: 0, // KE players going completely wild now
		ghostMisses: 0,
		health: 1.0,
		deaths: 0
	};

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

	public static var saveMap:Map<String, SaveScoreData> = [];

	public static var judgeTable:Array<Judgement> = [
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
			comboReturn: "FC"
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

	public static function resetScore():Void {
		stats.score = 0;
		stats.misses = 0;
		stats.ghostMisses = 0;
		stats.combo = 0;
		stats.breaks = 0;
		stats.health = 1;
		validScore = true;

		totalNotesHit = 0;
		totalMinesHit = 0;

		greatestJudgement = 0;
		noteRatingMod = 0.0001;
		accuracy = 0;

		for (i in 0...judgeTable.length) {
			if (!gottenJudges.exists(judgeTable[i].name))
				gottenJudges.set(judgeTable[i].name, 0);
		}

		curComboGrade = "";
		curGrade = "N/A";
	}

	public static function returnGradePercent():String {
		var floor = Math.floor(accuracy * 100) / 100;
		var sep = funkin.objects.ui.UI.separator;

		var finalPercent:String = '$floor%';
		if (curComboGrade != null && curComboGrade != '')
			finalPercent = '$floor% [$curComboGrade]';
		// finalPercent = '$floor%' + sep + curComboGrade;

		return ' $finalPercent';
	}

	public static function updateGradePercent(id:Int):Void {
		if (accuracy <= 0)
			accuracy = 0;
		if (accuracy >= 100)
			accuracy = 100;

		PlayerInfo.totalNotesHit++;
		noteRatingMod += (Math.max(0, id));
		updateGrade();
	}

	public static function updateGrade():Void {
		var biggestAccuracy:Float = 0;
		for (grade in gradeLetters.keys()) {
			if (gradeLetters.get(grade) <= accuracy && gradeLetters.get(grade) >= biggestAccuracy) {
				biggestAccuracy = gradeLetters.get(grade);
				curGrade = grade;
			}
		}

		curComboGrade = "";

		// Update FC Display;
		if (judgeTable[greatestJudgement].comboReturn != null)
			curComboGrade = judgeTable[greatestJudgement].comboReturn;

		if (stats.misses > 0)
			curComboGrade = (stats.misses < 10 ? 'SDCB' : '');
	}

	public static function increaseScore(rating:Int):Void {
		stats.score += judgeTable[rating].score;
		stats.health += 0.04 * (judgeTable[rating].health) / 100;

		if (stats.combo < 0)
			stats.combo = 0;
		stats.combo += 1;

		// increase gotten judges count
		gottenJudges.set(judgeTable[rating].name, gottenJudges.get(judgeTable[rating].name) + 1);

		// update combo breaks counter
		if (judgeTable[rating].causesBreak)
			stats.breaks = stats.misses + gottenJudges.get(judgeTable[rating].name);

		PlayerInfo.updateGradePercent(Std.int(judgeTable[rating].percentMod));

		if (stats.health > 2)
			stats.health = 2;
	}

	public static function decreaseScore():Void {
		stats.score += judgeTable[3].score;
		stats.health += 0.04 * (judgeTable[3].health) / 100;
		stats.misses += 1;

		stats.combo = 0;

		// update combo breaks counter
		if (judgeTable[3].causesBreak)
			stats.breaks = stats.misses + gottenJudges.get(judgeTable[3].name);

		PlayerInfo.updateGradePercent(Std.int(judgeTable[3].percentMod));

		if (stats.health < 0)
			stats.health = 0;
	}

	/**
		Functions for saving scores
	**/
	//
	public static function saveInfo(song:String, diff:Int = 0, data:SaveScoreData, mode:GameModes):Void {
		OptionsAPI.bindSave("Scores");

		if (saveMap.exists(song)) {
			var lowerScore:Bool = (saveMap.get(song).score < data.score);
			var lowerMisses:Bool = (saveMap.get(song).misses < data.misses);
			var lowerAccuracy:Bool = (saveMap.get(song).accuracy < data.accuracy);

			saveMap.set(song, {
				score: (lowerScore ? data.score : saveMap.get(song).score),
				misses: (lowerMisses ? data.misses : saveMap.get(song).misses),
				accuracy: (lowerAccuracy ? data.accuracy : saveMap.get(song).accuracy),
				difficulty: FeatherUtils.getDifficulty(diff),
				gameplayMode: mode,
			});
		} else {
			saveMap.set(song, {
				score: data.score,
				misses: data.misses,
				gameplayMode: mode,
				difficulty: FeatherUtils.getDifficulty(diff),
				accuracy: data.accuracy
			});
		}

		FlxG.save.data.highscores = saveMap;
		// FlxG.save.data.flush();
	}

	public static function getScore(song:String, diff:Int = 0, mode:GameModes):Int {
		OptionsAPI.bindSave("Scores");

		if (!saveMap.exists(song)) {
			saveMap.set(song, {
				score: 0,
				misses: 0,
				gameplayMode: mode,
				difficulty: FeatherUtils.getDifficulty(diff),
				accuracy: 0.00
			});
		}

		if (saveMap.get(song).difficulty == FeatherUtils.getDifficulty(diff))
			return saveMap.get(song).score;

		return 0;
	}

	public static function loadHighscores():Void {
		OptionsAPI.bindSave("Scores");

		if (FlxG.save.data.highscores != null)
			saveMap = FlxG.save.data.highscores;
	}
}
