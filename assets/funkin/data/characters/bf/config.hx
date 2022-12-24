function loadAnimations() {
	addByPrefix('idle', 'BF idle dance', 24);
	addByPrefix('hey', 'BF HEY!!', 24, false);
	addByPrefix('shaking', 'BF idle shaking', 24);

	addByPrefix('singUP', 'BF NOTE UP0', 24, false);
	addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
	addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
	addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
	addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
	addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
	addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
	addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

	addOffset('idle', -5, 0);
	addOffset('hey', -3, 5);
	addOffset('shaking', -6, 1);

	addOffset('singUP', -47, 28);
	addOffset('singLEFT', 4, -7);
	addOffset('singRIGHT', -48, -5);
	addOffset('singDOWN', -22, -51);
	addOffset('singUPmiss', -43, 28);
	addOffset('singLEFTmiss', 4, 19);
	addOffset('singRIGHTmiss', -42, 23);
	addOffset('singDOWNmiss', -22, -21);

	playAnim('idle');

	flipX = true;

	setBarColor([49, 176, 209]);
	setCamOffsets(0, -50);
	if (player)
		setOffsets(0, 100);
	else
		setOffsets(-135, 100);
}

var isOld:Bool = false;

function update(elapsed:Float) {
	if (FlxG.keys.justPressed.NINE) {
		isOld = !isOld;
		if (player) {
			PlayState.ui.iconP1.suffix = (isOld ? '-old' : '');
			PlayState.ui.iconP1.updateIcon('bf', true);
		} else {
			PlayState.ui.iconP2.suffix = (isOld ? '-old' : '');
			PlayState.ui.iconP2.updateIcon('bf', true);
		}
	}
}
