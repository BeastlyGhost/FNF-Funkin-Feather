package base.utils;

typedef Judgement =
{
	var name:String;
	var score:Int;
	var health:Float;
	var timingMod:Float;
	var percentMod:Float;
	var comboReturn:String;
}

class ScoreUtils
{
	public static var score:Int = 0;
	public static var misses:Int = 0;
	public static var combo:Int = 0;
	public static var health:Int = 1;

	public static var noteRatingMod:Float;
	public static var totalNotesHit:Int;
	public static var totalMinesHit:Int;

	public static var accuracy(get, default):Float;

	static function get_accuracy():Float
		return noteRatingMod / totalNotesHit;

	public static var curComboGrade:String;
	public static var curGrade:String;

	public static var highestJudgement:Int = 0;

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
			health: 20,
			percentMod: 50,
			timingMod: 133.33,
			comboReturn: "FC"
		},
		{
			name: "shit",
			score: -50,
			health: -50,
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
		highestJudgement = 0;
		noteRatingMod = 0.0001;

		curComboGrade = "";
		curGrade = "N/A";
	}

	public static function returnGradePercent()
	{
		var floor = Math.floor(accuracy * 100) / 100;

		var finalPercent:String = '$floor%';
		if (curComboGrade != null && curComboGrade != '')
			finalPercent = '$floor - $curComboGrade';

		updateGrade();

		return ' [$finalPercent]';
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
		if (judgeTable[highestJudgement].comboReturn != null)
			curComboGrade = judgeTable[highestJudgement].comboReturn;

		if (misses > 0 && misses < 10)
			curComboGrade = 'SDCB';
	}
}
