package funkin.objects.ui;

import flixel.util.FlxColor;
import flixel.math.FlxPoint;
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
	public var preset:String = 'default';

	public var defaultAlpha:Float = 0.8;
	public var glowsOnHit:Bool = true;
	public var colorSwap:AUColorSwap;

	public function new(index:Int, ?preset:String = 'default'):Void {
		super(x, y);

		alpha = defaultAlpha;

		this.index = index;
		this.preset = preset;

		if (colorSwap == null)
			colorSwap = ShaderTools.initAUCS();
		shader = colorSwap;

		updateHitbox();
		scrollFactor.set();
	}

	public override function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void {
		super.playAnim(AnimName);

		if (AnimName != 'static') {
			colorSwap.active = true;

			var indexColor:FlxColor = 0xFFFFFFFF;
			indexColor = colorPresets.get(preset)[index];

			if (AnimName == 'pressed') { // presses need to be colored differently than usual
				colorSwap.red = FlxColor.interpolate(indexColor, 0xFF9C9C9C, 0.6);
				colorSwap.blue = 0xFF201E31;
				colorSwap.green = 0xFFFFFFFF;
			}
			else {
				FunkinAssets.setColorSwap(index, colorSwap);
			}
		} else {
			// else just declare the shader as inactive
			colorSwap.active = false;
		}

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

	public var speed:Float;

	public var step:Float = 0;
	public var index:Int = 0;

	public var noteDisplace:FlxPoint = new FlxPoint(0, 0);

	/**
		Sustain Notes
	**/
	public var holdDisplace:FlxPoint = new FlxPoint(0, 0);

	public var sustainLength:Float = 0;

	public var isSustain:Bool = false;
	public var isSustainEnd:Bool = false;

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

		switch (type) {
			default:
				try {
					// may be the cause of a memory leak??
					if (colorSwap == null)
						colorSwap = ShaderTools.initAUCS();
					FunkinAssets.generateNotes(this, index, isSustain);
					shader = colorSwap;
					FunkinAssets.setColorSwap(index, colorSwap);
				}
				catch (e:Dynamic) {
					this.destroy();
					return;
				}
		}

		if (!isSustain)
			playAnim('scroll');
		else {
			judgeData.earlyHitMult = 0.5;

			parentNote = prevNote;
			while (parentNote.isSustain && parentNote.prevNote != null)
				parentNote = parentNote.prevNote;
			parentNote.children.push(this);
		}

		noteDisplace.x += 15;

		if (isSustain && prevNote != null) {
			playAnim('end');
			updateHitbox();

			speed = prevNote.speed;
			alpha = 0.6;

			noteDisplace.x = width / 2 + holdDisplace.x;

			if (PlayState.assetSkin == 'pixel')
				noteDisplace.x += 30;

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

		if (colorSwap == null)
			colorSwap = ShaderTools.initAUCS();

		try {
			switch (OptionsAPI.getPref("UI Style").toLowerCase()) {
				case "feather":
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

		loadGraphic(AssetHelper.grabAsset("splash_feather", IMAGE, "images/notes"), true, 500, 500);

		for (i in 0...2)
			animation.add('impact$i', [0, 1, 2, 3, 4, 5, 6, 7, 8], 20, false);
		setGraphicSize(Std.int(width * 0.4));
		offsetX = 170;
		offsetY = 170;

		shader = colorSwap;
		setupNoteSplash(x, y, index);
	}

	public function setupNoteSplash(x:Float, y:Float, index:Int = 0, step:Float = 0, preset:String = 'default'):Void {
		ID = index;

		if (graphic == null)
			return;

		setPosition(x, y);
		animation.play('impact${FlxG.random.int(0, 1)}', true);
		updateHitbox();

		offset.set(offsetX, offsetY);
		FunkinAssets.setColorSwap(index, colorSwap);
	}

	public override function update(elapsed:Float):Void {
		if (animation.curAnim != null && animation.curAnim.finished)
			kill();

		super.update(elapsed);
	}
}
