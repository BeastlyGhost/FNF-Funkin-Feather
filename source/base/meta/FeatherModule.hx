package base.meta;

class FeatherModule extends SScript
{
	public function new(file:String, ?preset:Bool = true)
	{
		super(file, preset);
		traces = false;
	}

	override public function preset():Void
	{
		super.preset();

		// here we set up the built-in imports
		// these should work on *any* script;

		// CLASSES (HAXE)
		set('Type', Type);
		set('Math', Math);
		set('Std', Std);
		set('Date', Date);

		// CLASSES (FLIXEL);
		set('FlxG', flixel.FlxG);
		set('FlxBasic', flixel.FlxBasic);
		set('FlxObject', flixel.FlxObject);
		set('FlxSprite', flixel.FlxSprite);
		set('FlxSound', flixel.system.FlxSound);
		set('FlxSort', flixel.util.FlxSort);
		set('FlxStringUtil', flixel.util.FlxStringUtil);
		set('FlxState', flixel.FlxState);
		set('FlxSubState', flixel.FlxSubState);
		set('FlxText', flixel.text.FlxText);
		set('FlxTimer', flixel.util.FlxTimer);
		set('FlxTween', flixel.tweens.FlxTween);
		set('FlxEase', flixel.tweens.FlxEase);
		set('FlxTrail', flixel.addons.effects.FlxTrail);

		// CLASSES (FUNKIN);
		set('Alphabet', funkin.objects.ui.Alphabet);
		set('Player', funkin.objects.Character.Player);
		set('Character', funkin.objects.Character);
		set('Conductor', funkin.song.Conductor);
		set('Icon', funkin.objects.ui.Icon);
		set('Strum', funkin.objects.ui.notes.Strum);
		set('BabyArrow', funkin.objects.ui.notes.Strum.BabyArrow);
		set('Note', funkin.objects.ui.notes.Note);
		set('game', funkin.states.PlayState.main);
		set('PlayState', funkin.states.PlayState);
		set('Paths', Paths);

		// CLASSES (FEATHER);
		set('Main', Main);
		set('Stage', funkin.objects.Stage);
		set('OptionsMeta', OptionsMeta);
		set('FeatherTools', base.utils.FeatherTools);
		set('FeatherSprite', base.utils.FeatherTools.FeatherSprite);
		set('Controls', base.backend.Controls);
	}
}

class EventModule
{
	public static var eventArray:Array<String> = [];
	public static var needsValue3:Array<String> = [];

	// public static var loadedEvents:Array<FeatherModule> = [];
	// public static var pushedEvents:Array<String> = [];
	public static var loadedEvents:Map<String, FeatherModule> = [];

	public static function getScriptEvents()
	{
		loadedEvents.clear();
		eventArray = [];

		var myEvents:Array<String> = [];

		for (event in sys.FileSystem.readDirectory('assets/data/events'))
		{
			if (event.contains('.'))
			{
				event = event.substring(0, event.indexOf('.', 0));
				loadedEvents.set(event, new FeatherModule(AssetHandler.grabAsset('$event', MODULE, 'data/events')));
				// trace('new event module loaded: ' + event);
				myEvents.push(event);
			}
		}
		myEvents.sort(function(e1, e2) return Reflect.compare(e1.toLowerCase(), e2.toLowerCase()));

		for (e in myEvents)
		{
			if (!eventArray.contains(e))
				eventArray.push(e);
		}
		eventArray.insert(0, '');

		for (e in eventArray)
			returnValue3(e);

		myEvents = [];
	}

	inline public static function returnValue3(event:String):Array<String>
	{
		if (loadedEvents.exists(event))
		{
			var script:FeatherModule = loadedEvents.get(event);
			var scriptCall = script.call('returnValue3', []);

			if (scriptCall != null)
			{
				needsValue3.push(event);
				// trace(needsValue3);
			}
		}
		return needsValue3.copy();
	}

	inline public static function returnEventDescription(event:String):String
	{
		if (loadedEvents.exists(event))
		{
			var script:FeatherModule = loadedEvents.get(event);
			var descString = script.call('returnDescription', []);
			return descString;
		}
		trace('Event $event has no description.');
		return '';
	}
}
