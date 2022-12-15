function createCheckmark(box)
{
	box.frames = Paths.getSparrowAtlas('menus/optionsMenu/checkboxThingie');
	box.animation.addByPrefix('true', 'Check Box unselected', 24, false);
	box.animation.addByPrefix('false', 'Check Box selecting animation', 24, false);

	box.addOffset('true', 0, -30);
	box.addOffset('false', 25, 55);

	box.setGraphicSize(Std.int(box.width * 0.7));
	box.updateHitbox();
}
