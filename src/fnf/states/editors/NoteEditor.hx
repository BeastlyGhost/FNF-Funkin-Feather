package fnf.states.editors;

import feather.BaseMenu.BaseSubMenu;
import feather.tools.shaders.AUColorSwap;
import flixel.FlxG;
import flixel.addons.display.shapes.FlxShapeBox;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import fnf.objects.ui.Note;
import fnf.song.MusicState;

class NoteEditor extends BaseSubMenu {
	public var selector:FlxShapeBox;
	public var notes:FlxTypedSpriteGroup<PlumaSprite>;

	public var indexSelection:Int = 0;

	public var shaders:Array<AUColorSwap> = [];

	public var presetName:String = 'my preset';
	public var result:Array<Int> = [0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF];

	public var keys:Int = 4;

	override function create():Void {
		super.create();

		bgImage = 'menuDesat';
		menuBG.color = 0xFFEA71FD;

		notes = new FlxTypedSpriteGroup<PlumaSprite>();

		selector = new FlxShapeBox(0, 0, 90, 80, {thickness: 15}, 0xFF000000);

		for (index in 0...keys) {
			// 0, 1, 2... keys amount
			wrappableGroup.push(index);
			trace(wrappableGroup);

			var note:PlumaSprite = new PlumaSprite(0, 0);
			note.frames = AssetHelper.grabAsset('notes', SPARROW, 'images/notes');

			note.animation.addByPrefix('scroll', 'note0');
			note.animation.addByPrefix('hold', 'note hold');
			note.animation.addByPrefix('end', 'note end');

			note.antialiasing = true;

			note.setGraphicSize(Std.int(note.width * 0.7));

			notes.screenCenter(XY);
			note.x += (index - ((keys / 2))) * (160 * 0.7);

			note.playAnim('scroll');

			note.angle = (index == 0 ? -90 : index == 3 ? 90 : index == 1 ? 180 : 0);

			notes.add(note);
		}

		add(notes);

		selector.alpha = 0.6;
		selector.screenCenter(XY);
		add(selector);

		updateSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		updateSelection(Controls.isJustPressed("left") ? -1 : Controls.isJustPressed("right") ? 1 : 0);

		if (Controls.isJustPressed("back"))
			close();
	}

	public override function updateSelection(newSelection:Int = 0):Void {
		super.updateSelection(newSelection);

		if (newSelection != 0)
			FSound.playSound("scrollMenu", 'sounds/menus');

		var blah:Int = 0;
		if (blah == selection) {
			selector.x = notes.x;
			selector.y = notes.y;
		}
		blah++;
	}

	override function close():Void {
		BabyArrow.colorPresets.set(presetName, result);
		super.close();
	}
}
