function scriptCreate() {
	// triggered when a script is successfully created
}

function postCreate() {
	// triggered after playstate's stages and characters are generated
}

function songCutscene() {
	// prior to starting the countdown on playstate
	// can be used for song cutscenes
}

function songCutsceneEnd() {
	// prior to fully ending a song on playstate
	// can be used for song cutscenes
}

function startCountdown() {
	// when the countdown starts on playstate
}

function countdownTick(tick:Int) {
	// when the countdown is ticking on playstate
}

function startSong() {
	// when the song just started at playstate
}

function update(elapsed:Float) {
	// every frame on playstate
}

function postUpdate(elapsed:Float) {
	// after every frame on playstate
}

function onDeath() {
	// when you die on playstate
}

function onKeyPress(key:Int, action:String, isGamepad:Bool) {
	// when you press a key on playstate
}

function onKeyRelease(key:Int, action:String, isGamepad:Bool) {
	// when you release a key on playstate
}

function goodNoteHit(note:Note, strum:Strum) {
	// when you hit a note on playstate
	// NOTICE: use `if (!note.mustPress)` for opponent notes!!!
}

function beatHit(curBeat:Int) {
	// when a song beat is hit on playstate
}

function stepHit(curStep:Int) {
	// when a song step is hit on playstate
}

function sectionHit(curSection:Int) {
	// when a song section is hit on playstate
}

function openSubState() {
	// when you close a substate on playstate
}

function closeSubState() {
	// when you close a substate on playstate
}

function endSong() {
	// when the song is ending on playstate
}
