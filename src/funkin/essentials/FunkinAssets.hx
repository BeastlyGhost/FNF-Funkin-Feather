package funkin.essentials;

import flixel.util.FlxColor;
import feather.tools.shaders.AUColorSwap;
import funkin.essentials.PlayerInfo;
import funkin.objects.ui.Note;
import funkin.states.PlayState;

/**
	FunkinAssets matches together a lot of functions for creating assets
**/
class FunkinAssets {
	/**
		Pop Ups, like Ratings and Combo
	**/
	public static function generateRating(skin:String = 'default'):PlumaSprite {
		var width:Int = (skin == "pixel" ? 60 : 352);
		var height:Int = (skin == "pixel" ? 21 : 155);

		var rating:PlumaSprite = new PlumaSprite();
		rating.loadGraphic(AssetHelper.grabAsset("ratings", IMAGE, "images/ui/" + skin), true, width, height);

		for (i in 0...PlayerInfo.judgeTable.length)
			rating.animation.add(PlayerInfo.judgeTable[i].name, [i]);

		rating.setGraphicSize(Std.int(rating.width * (skin == "pixel" ? PlayState.pixelAssetSize : 0.7)));
		rating.updateHitbox();

		rating.antialiasing = (skin != "pixel");

		return rating;
	}

	public static function generateCombo(skin:String = 'default'):PlumaSprite {
		var width:Int = (skin == "pixel" ? 12 : 108);
		var height:Int = (skin == "pixel" ? 12 : 142);

		var combo:PlumaSprite = new PlumaSprite();
		combo.loadGraphic(AssetHelper.grabAsset("combo_numbers", IMAGE, "images/ui/" + skin), true, width, height);

		for (i in 0...10)
			combo.animation.add('num' + i, [i]);

		combo.setGraphicSize(Std.int(combo.width * (skin == "pixel" ? PlayState.pixelAssetSize : 0.5)));
		combo.updateHitbox();

		combo.antialiasing = (skin != "pixel");

		return combo;
	}

	/**
		Notes
	**/
	public static function generateStrums(babyArrow:BabyArrow, index:Int, ?texture:String = 'NOTE_assets'):BabyArrow {
		switch (PlayState.assetSkin) {
			default:
				babyArrow.frames = AssetHelper.grabAsset('notes', SPARROW, 'images/notes');

				babyArrow.animation.addByPrefix('static', 'strum0');
				babyArrow.animation.addByPrefix('pressed', 'strum press', 24, false);
				babyArrow.animation.addByPrefix('confirm', 'strum confirm', 24, false);

				babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
				babyArrow.antialiasing = true;
		}

		return babyArrow;
	}

	public static function generateNotes(note:Note, index:Int, isSustain:Bool = false):Note {
		switch (PlayState.assetSkin) {
			default:
				note.frames = AssetHelper.grabAsset('notes', SPARROW, 'images/notes');

				note.animation.addByPrefix('scroll', 'note0');
				note.animation.addByPrefix('hold', 'note hold');
				note.animation.addByPrefix('end', 'note end');

				if (!isSustain) {
					note.angle = (index == 0 ? -90 : index == 3 ? 90 : index == 1 ? 180 : 0);
				}

				note.setGraphicSize(Std.int(note.width * 0.7));
				note.antialiasing = true;
				note.updateHitbox();
		}

		return note;
	}

	public static function setColorSwap(idx:Int, colorSwap:AUColorSwap):Void {
		if (colorSwap == null)
			return;

		var colorF:FlxColor;

		if (OptionsAPI.getPref("Quant Style").toLowerCase() != 'none') {
			colorF = BabyArrow.colorPresets.get('quants-${OptionsAPI.getPref("Quant Style").toLowerCase()}')[idx];
		} else {
			colorF = BabyArrow.colorPresets.get(PlayState.assetSkin)[idx];
		}

		colorSwap.red = colorF;
		colorSwap.green = 0xFFFFFFFF;
		colorSwap.blue = colorF;
	}
}
