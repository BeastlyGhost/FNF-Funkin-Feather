function loadAnimations() {
	character.animation.addByPrefix('firstDeath', "BF dies", 24, false);
	character.animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
	character.animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

	character.addOffset("firstDeath", -10, 0);
	character.addOffset("deathConfirm", -10, 0);
	character.addOffset("deathLoop", -10, 0);

	character.flipX = true;

	if (character.player)
		set('flipX', true);
	else
		set('flipX', false);
}
