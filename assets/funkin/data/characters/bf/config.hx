function loadAnimations() {
	character.animation.addByPrefix('idle', 'BF idle dance', 24);
	character.animation.addByPrefix('hey', 'BF HEY!!', 24, false);
	character.animation.addByPrefix('shaking', 'BF idle shaking', 24);

	character.animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
	character.animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
	character.animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
	character.animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
	character.animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
	character.animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
	character.animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
	character.animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

	character.addOffset('idle', -5, 0);
	character.addOffset('hey', -3, 5);
	character.addOffset('shaking', -6, 1);

	character.addOffset('singUP', -47, 28);
	character.addOffset('singLEFT', 4, -7);
	character.addOffset('singRIGHT', -48, -5);
	character.addOffset('singDOWN', -22, -51);
	character.addOffset('singUPmiss', -43, 28);
	character.addOffset('singLEFTmiss', 4, 19);
	character.addOffset('singRIGHTmiss', -42, 23);
	character.addOffset('singDOWNmiss', -22, -21);

	character.playAnim('idle');

	character.flipX = true;

	character.setBarColor([49, 176, 209]);
	character.camOffset.set(0, -50);

	if (character.player)
		character.charOffset.set(0, 100);
	else
		character.charOffset.set(-135, 100);
}

var isOld:Bool = false;

function update(elapsed:Float) {
	if (FlxG.keys.justPressed.NINE) {
		isOld = !isOld;
		if (character.player) {
			PlayState.ui.iconP1.suffix = (isOld ? '-old' : '');
			PlayState.ui.iconP1.updateIcon('bf', true);
		} else {
			PlayState.ui.iconP2.suffix = (isOld ? '-old' : '');
			PlayState.ui.iconP2.updateIcon('bf', true);
		}
	}
}
