function loadAnimations()
{
	addByPrefix('firstDeath', "BF dies", 24, false);
	addByPrefix('deathLoop', "BF Dead Loop", 24, true);
	addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

	addOffset("firstDeath", -10, 0);
	addOffset("deathConfirm", -10, 0);
	addOffset("deathLoop", -10, 0);

	characterData.antialiasing = true;
	characterData.flipX = true;

	if (isPlayer)
		set('flipX', true);
	else
		set('flipX', false);
}
