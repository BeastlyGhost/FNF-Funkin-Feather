package funkin.states.menus;

import funkin.song.MusicState;

typedef CreditsData =
{
	var mainBG:String;
	var mainBGColor:String;
	var shouldChangeColor:Bool;
	var creditsList:Array<CreditsUserData>;
}

typedef CreditsUserData =
{
	var name:String;
	var profession:String;
	var description:String;
	var socials:Array<String>;
	var icon:String;
}

class CreditsMenu extends MusicBeatState {}
