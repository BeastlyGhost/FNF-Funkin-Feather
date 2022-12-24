package funkin.objects.ui.notes;

import feather.tools.FeatherToolkit.PlumaSprite;
import feather.tools.shaders.AUColorSwap;
import feather.tools.shaders.ShaderTools;
import flixel.FlxG;
import funkin.essentials.song.Conductor;
import funkin.states.PlayState;

// just to make it easier to add into note parameters and such
typedef DefaultNote = {
	var canBeHit:Bool;
	var mustPress:Bool;
	var wasGoodHit:Bool;
	var tooLate:Bool;
}

typedef NoteType = {
	var type:String;
	var lowPriority:Bool;
	var ignoreNote:Bool;
	var doSplash:Bool;
	var isMine:Bool;
	var canDie:Bool;
}

typedef NoteJudge = {
	var earlyHitMult:Float;
	var lateHitMult:Float;
	var missOffset:Float;
}

/**
	`BabyArrow`s are sprites that are attached to your `Strum`line,
	this class simply initializes said `BabyArrow`s
**/
class BabyArrow extends PlumaSprite {
	public var swagWidth:Float = 160 * 0.7;

	public static var actions:Array<String> = ['left', 'down', 'up', 'right'];
	public static var colors:Array<String> = ['purple', 'blue', 'green', 'red'];

	/**
		for Notes
	**/
	public static var colorPresets:Map<String, Array<Int>> = [
		"default" => [0xFFC24C9A, 0xFF03FFFF, 0xFF12FA05, 0xFFF9393F],
		// 4th, 8th, 16th, 24th, 32nd, 48th, 64th, 96th, 128th, 192nd
		"quants-stepmania" => [
			0xFFFF0000, 0xFF0000FF, 0xFF662D91, 0xFFFFFF00, 0xFFFF00FF, 0xFFF7941D, 0xFF00FFFF, 0xFF00C600, 0xFFFF9999, 0xFF9999FF,
		],
		// Credits: @cubicyoshi, @neolixn
		"quants-forever" => [
			0xFFFF3535, 0xFF536BEF, 0xFFC24B99, 0xFF00E550, 0xFF606789, 0xFFFF7AD7, 0xFFFFE83E, 0xFFAE36E6, 0xFF0FEBFF, 0xFF606789,
		],
	];

	public var index:Int = 0;
	public var defaultAlpha:Float = 0.8;
	public var glowsOnHit:Bool = true;
	public var colorSwap:AUColorSwap;

	public function new(index:Int, ?preset:String = 'default'):Void {
		super(x, y);

		colorSwap = ShaderTools.initAUCS();

		alpha = defaultAlpha;

		this.index = index;

		updateHitbox();
		scrollFactor.set();
	}

	public override function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void {
		super.playAnim(AnimName);

		if (AnimName != 'static')
			FunkinAssets.setColorSwap(index, colorSwap);

		centerOffsets();
		centerOrigin();
	}
}

/**
	Note class, initializes *scrolling* notes for the main game
**/
class Note extends PlumaSprite {
	public var noteTypes:Array<String> = ['default', 'mine'];

	public var noteData:DefaultNote = {
		canBeHit: false,
		mustPress: false,
		wasGoodHit: false,
		tooLate: false
	};

	public var typeData:NoteType = {
		type: 'default',
		lowPriority: false,
		ignoreNote: false,
		doSplash: false,
		isMine: false,
		canDie: true
	};

	// modifiable gameplay variables
	public var judgeData:NoteJudge = {
		earlyHitMult: 1,
		lateHitMult: 1,
		missOffset: 200
	};

	public var babyArrow:BabyArrow;
	public var colorSwap:AUColorSwap;

	public var prevNote:Note;
	public var parentNote:Note;
	public var children:Array<Note> = [];

	public var speed:Float = 1;

	public var step:Float = 0;
	public var index:Int = 0;

	public var sustainLength:Float = 0;
	public var isSustain:Bool = false;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	public function new(step:Float, index:Int, type:String, isSustain:Bool = false, ?prevNote:Note):Void {
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		super(0, -2000);

		if (prevNote == null)
			prevNote = this;

		this.step = step;
		this.index = index;
		typeData.type = type;

		this.prevNote = prevNote;
		this.isSustain = isSustain;

		babyArrow = new BabyArrow(index);
		colorSwap = ShaderTools.initAUCS();

		FunkinAssets.generateNotes(this, index, isSustain);
		FunkinAssets.setColorSwap(index, colorSwap);

		if (!isSustain)
			playAnim('scroll');
		else {
			judgeData.earlyHitMult = 0.5;

			parentNote = prevNote;
			while (parentNote.isSustain && parentNote.prevNote != null)
				parentNote = parentNote.prevNote;
			parentNote.children.push(this);
		}

		offsetX += 15;

		if (isSustain && prevNote != null) {
			playAnim('end');
			updateHitbox();

			speed = prevNote.speed;
			alpha = 0.6;

			offsetX = width / 2;
			offsetX -= width / 2;

			if (PlayState.assetSkin == 'pixel')
				offsetX += 30;

			if (prevNote.isSustain) {
				prevNote.playAnim('hold');
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.song.speed;
				prevNote.updateHitbox();
			}
		}
	}

	public var lastStep:Float = 0;

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (noteData.mustPress) {
			noteData.canBeHit = (step > Conductor.songPosition - Conductor.safeZoneOffset * judgeData.lateHitMult
				&& step < Conductor.songPosition + Conductor.safeZoneOffset * judgeData.earlyHitMult);
		} else
			noteData.canBeHit = false;

		if (noteData.tooLate || (prevNote != null && prevNote.isSustain && prevNote.noteData.tooLate)) {
			if (alpha > 0.3)
				alpha = 0.3;
		}

		if (lastStep < step) {
			lastStep = step;

			// if (OptionsAPI.getPref("Note Quant Style") != 'none')
			//    flushIndex();
		}
	}
}

class Splash extends PlumaSprite {
	public var offsetX:Int = 0;
	public var offsetY:Int = 0;

	var colorSwap:AUColorSwap;

	public function new(x:Float, y:Float, index:Int = 0):Void {
		super(x, y);

		ID = index;

		colorSwap = ShaderTools.initAUCS();

		try {
			switch (OptionsAPI.getPref("User Interface Style")) {
				case "Feather":
					loadGraphic(AssetHelper.grabAsset("splash_feather", IMAGE, "images/notes"), true, 500, 500);
					for (i in 0...2)
						animation.add('impact$i', [0, 1, 2, 3, 4, 5, 6, 7, 8], 20, false);
					setGraphicSize(Std.int(width * 0.4));
					offsetX = 170;
					offsetY = 170;
				default:
					frames = AssetHelper.grabAsset("noteSplashes", SPARROW, "data/notes/default");
					for (i in 0...3)
						animation.addByPrefix('impact$i', 'note impact $i ${BabyArrow.colors[index]}', 24, false);
					offsetX = 60;
					offsetY = 30;
			}
		}
		catch (e:Dynamic) {
			this.destroy();
			throw("Something went wrong while setting up Note Splashes, Error: " + e);
			return;
		}

		if (colorSwap != null)
			shader = colorSwap;

		setupNoteSplash(x, y, index);
	}

	public function setupNoteSplash(x:Float, y:Float, index:Int = 0, step:Float = 0, preset:String = 'default'):Void {
		ID = index;

		if (graphic == null) {
			this.destroy();
			return;
		}

		if (colorSwap != null)
			FunkinAssets.setColorSwap(index, colorSwap);

		setPosition(x, y);
		animation.play('impact${FlxG.random.int(0, 1)}', true);
		updateHitbox();
		offset.set(offsetX, offsetY);
	}

	public override function update(elapsed:Float):Void {
		if (animation.curAnim != null && animation.curAnim.finished)
			kill();

		super.update(elapsed);
	}
}

/**
	Quant Note Helper

	@since INFDEV
**/
class Quant {
	// based on forever engine
	private var quantIdx:Array<Int> = [4, 8, 12, 16, 20, 24, 32, 48, 64, 192];

	public var index:Int = -1;
	public var indexes:Array<Int> = [];

	public function flushIndex(step:Float):Void {
		// refresh quant index
		var bpmConditional:Float = (60 / Conductor.bpm);
		var bpmTime:Float = bpmConditional * 1000;

		var measureTime:Float = (bpmTime) * 4;
		var lowestDeviation:Float = measureTime / quantIdx[quantIdx.length - 1];

		if (index == -1) {
			try {
				for (q in 0...quantIdx.length) {
					final finalTime:Float = (measureTime / quantIdx[q]);
					if ((step + lowestDeviation) % finalTime < lowestDeviation * 2) {
						trace('index for quant note is $q');
						index = q;
						break;
					}
				}
			}
			catch (e:Dynamic)
				throw("Quant Index was null??? - " + index);
		}
	}
}
