package funkin.states.editors;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import funkin.essentials.song.MusicState;
import funkin.objects.Character;
import funkin.objects.Stage;
import funkin.states.menus.MainMenu;

class OffsetEditor extends MusicBeatState
{
	var debugChar:Character;
	var charName:String = 'bf';
	var player:Bool = false;

	var offsetText:FlxText;
	var textGroup:FlxTypedGroup<FlxText>;

	var animSelection:Int = 0;
	var animList:Array<String> = [];

	var defaultIdle:Array<String> = ['idle', 'danceLeft', 'danceRight'];

	var camFollow:FlxObject;
	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	public override function new(?charName:String, ?player:Bool = false):Void
	{
		super();

		this.charName = charName;
		this.player = player;
	}

	public override function create():Void
	{
		super.create();

		DiscordRPC.update("OFFSET EDITOR", "Character: " + charName);

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		add(new Stage().setStage('stage'));

		debugChar = new Character(player).setCharacter(770, 100, charName);
		debugChar.isDebug = true;
		add(debugChar);

		for (idle in defaultIdle)
			if (debugChar.animation.getByName(idle) != null)
				debugChar.playAnim(idle);

		textGroup = new FlxTypedGroup<FlxText>();
		add(textGroup);

		offsetText = new FlxText(300, 16);
		offsetText.size = 26;
		offsetText.scrollFactor.set();
		offsetText.cameras = [camHUD];
		add(offsetText);

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		reloadText();
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		offsetText.text = (debugChar.animation.curAnim.name != null ? debugChar.animation.curAnim.name : '');

		mainControls(elapsed);
		editorInput(elapsed);

		if (Controls.isJustPressed("back"))
			MusicState.switchState(new MainMenu());
	}

	public function reloadText():Void
	{
		textGroup.forEach(function(text:FlxText)
		{
			if (text != null)
			{
				text.kill();
				textGroup.remove(text, true);
			}
		});

		var loopInt:Int = 0;

		var len:Int = textGroup.members.length - 1;
		while (len >= 0)
		{
			var memb:FlxText = textGroup.members[len];
			if (memb != null)
			{
				memb.kill();
				textGroup.remove(memb);
				memb.destroy();
			}
			--len;
		}
		textGroup.clear();

		for (name => offsets in debugChar.animOffsets)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * loopInt), 0, name + ": " + offsets, 15);
			text.scrollFactor.set();
			text.cameras = [camHUD];
			textGroup.add(text);

			if (!animList.contains(name))
				animList.push(name);

			loopInt++;
		}
	}

	public function mainControls(elapsed:Float):Void
	{
		if (FlxG.keys.pressed.E)
			FlxG.camera.zoom += elapsed * FlxG.camera.zoom;
		if (FlxG.keys.pressed.Q)
			FlxG.camera.zoom -= elapsed * FlxG.camera.zoom;

		if (FlxG.keys.justPressed.F)
			debugChar.flipX = !debugChar.flipX;

		if (FlxG.camera.zoom > 3)
			FlxG.camera.zoom = 3;
		if (FlxG.camera.zoom < 0.1)
			FlxG.camera.zoom = 0.1;
	}

	public function editorInput(elapsed:Float):Void
	{
		var holdingCtrl = FlxG.keys.pressed.CONTROL;

		var charControls:Array<Bool> = [FlxG.keys.justPressed.W, FlxG.keys.justPressed.S, FlxG.keys.justPressed.SPACE];
		var camControls:Array<Bool> = [
			FlxG.keys.pressed.J,
			FlxG.keys.pressed.K,
			FlxG.keys.pressed.I,
			FlxG.keys.pressed.L
		];
		var moveControls:Array<Bool> = [
			(holdingCtrl ? FlxG.keys.pressed.UP : FlxG.keys.justPressed.UP),
			(holdingCtrl ? FlxG.keys.pressed.DOWN : FlxG.keys.justPressed.DOWN),
			(holdingCtrl ? FlxG.keys.pressed.LEFT : FlxG.keys.justPressed.LEFT),
			(holdingCtrl ? FlxG.keys.pressed.RIGHT : FlxG.keys.justPressed.RIGHT)
		];

		if (moveControls.contains(true))
		{
			for (i in 0...moveControls.length)
			{
				var speedMult = 1;
				var negValue:Int = 1;
				var posValue = 0;

				if (FlxG.keys.pressed.SHIFT)
					speedMult = 10;
				if (i % 2 == 1)
					negValue = -1;
				if (i > 1)
					posValue = 1;

				if (debugChar.animOffsets.get(debugChar.animation.curAnim.name) != null)
					debugChar.animOffsets.get(debugChar.animation.curAnim.name)[posValue] += negValue * speedMult;

				debugChar.playAnim(animList[animSelection]);
				reloadText();
			}
		}

		if (charControls.contains(true))
		{
			for (i in 0...charControls.length)
			{
				if (charControls[i] == true)
				{
					if (i == 0)
						animSelection--;
					else if (i == 1)
						animSelection++;

					animSelection = FlxMath.wrap(animSelection, 0, animList.length - 1);

					debugChar.playAnim(animList[animSelection]);
					reloadText();
				}
			}
		}

		if (camControls.contains(true))
		{
			for (i in 0...camControls.length)
			{
				if (camControls[i] == true)
				{
					var speed:Float = 500 * elapsed;
					if (FlxG.keys.pressed.SHIFT)
						speed *= 4;

					if (i == 0) // left
						camFollow.x -= speed;
					else if (i == 3) // right
						camFollow.x += speed;

					if (i == 1) // down
						camFollow.y += speed;
					else if (i == 2) // up
						camFollow.y -= speed;
				}
			}
		}
	}
}
