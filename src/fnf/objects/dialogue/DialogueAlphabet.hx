package fnf.objects.dialogue;

import fnf.objects.ui.Alphabet;

/**
	a `Alphabet` extension, for dialogue boxes
**/
class DialogueAlphabet extends Alphabet {
	public var speed:Float = 1;
	public var sounds:Array<String> = ['GF_1', 'GF_2', 'GF_3'];
	public var paused:Bool = false;
}
