function onCreate():Void
{
	var bg:PlumaSprite = new PlumaSprite(-600, -200);
	bg.loadGraphic(Paths.image('stageback'));
	bg.scrollFactor.set(0.9, 0.9);
	add(bg);

	var stageFront:PlumaSprite = new PlumaSprite(-650, 600);
	stageFront.loadGraphic(Paths.image('stagefront'));
	stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
	stageFront.scrollFactor.set(0.9, 0.9);
	stageFront.updateHitbox();
	add(stageFront);

	var stageCurtains:PlumaSprite = new PlumaSprite(-500, -300);
	stageCurtains.loadGraphic(Paths.image('stagecurtains'));
	stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
	stageCurtains.scrollFactor.set(1.3, 1.3);
	stageCurtains.updateHitbox();
	add(stageCurtains);
}
