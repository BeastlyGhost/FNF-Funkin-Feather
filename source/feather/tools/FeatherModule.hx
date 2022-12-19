package feather.tools;

class FeatherModule extends SScript
{
	public var scriptLibrary:AssetLibrary;

	public function new(file:String, ?directory:String = null, ?preset:Bool = true):Void
	{
		super(file, preset);
		traces = false;

		scriptLibrary = setLibrary(directory);
	}

	private function setLibrary(path:String):AssetLibrary
	{
		if (path == null)
			return null;

		var newLibrary:AssetLibrary = new AssetLibrary(path);

		set('Paths', newLibrary);

		return newLibrary;
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
		set('FlxSprite', flixel.FlxSprite);
		set('FlxSound', flixel.system.FlxSound);

		// CLASSES (FUNKIN);
		set('Alphabet', funkin.objects.ui.fonts.Alphabet);
		set('Character', funkin.objects.Character);
		set('Conductor', funkin.essentials.song.Conductor);
		set('Icon', funkin.objects.ui.Icon);
		set('Strum', funkin.objects.ui.notes.Strum);
		set('Strumline', funkin.objects.ui.notes.Strum);
		set('BabyArrow', funkin.objects.ui.notes.BabyArrow);
		set('Note', funkin.objects.ui.notes.Note);
		set('game', funkin.states.PlayState.main);
		set('PlayState', funkin.states.PlayState);
		if (scriptLibrary == null)
			set('Paths', Paths);

		// CLASSES (FEATHER);
		set('Stage', funkin.objects.Stage);
		set('OptionsAPI', feather.OptionsAPI);
		set('FeatherTools', feather.tools.FeatherTools);
		set('FeatherSprite', feather.tools.FeatherSpriteManager.FeatherSprite);
		set('ChildSprite', feather.tools.FeatherSpriteManager.ChildSprite);
		set('Controls', funkin.backend.Controls);

		#if windows
		set('platform', 'windows');
		#elseif linux
		set('platform', 'linux');
		#elseif mac
		set('platform', 'mac');
		#elseif android
		set('platform', 'android');
		#elseif html5
		set('platform', 'html5');
		#elseif flash
		set('platform', 'flash');
		#else
		set('platform', 'unknown');
		#end
	}

	public static function createInstance(moduleArray:Array<FeatherModule>):Array<FeatherModule>
	{
		// set up the modules folder
		var dirs:Array<Array<String>> = [
			FeatherTools.absoluteDirectory('scripts'),
			FeatherTools.absoluteDirectory('data/songs/${funkin.states.PlayState.song.name.toLowerCase()}')
		];

		var pushedModules:Array<String> = [];

		for (directory in dirs)
		{
			// it's 2am rn i'm dying give me a break
			var tempExts = ['.hx', '.hxs', '.hxc', '.hscript'];

			for (script in directory)
			{
				for (ext in tempExts)
				{
					if (directory != null && directory.length > 0)
					{
						if (!pushedModules.contains(script) && script != null && script.endsWith(ext))
						{
							moduleArray.push(new FeatherModule(script));
							// trace('new script module loaded: ' + script);
							pushedModules.push(script);
						}
					}
				}
			}
		}

		if (moduleArray != null)
		{
			for (i in moduleArray)
				i.call('onCreate', []);
		}

		return moduleArray;
	}
}

class EventModule
{
	public static var eventArray:Array<String> = [];
	public static var needsValue3:Array<String> = [];

	// public static var loadedEvents:Array<FeatherModule> = [];
	// public static var pushedEvents:Array<String> = [];
	public static var loadedEvents:Map<String, FeatherModule> = [];

	public static function getScriptEvents():Void
	{
		loadedEvents.clear();
		eventArray = [];

		var myEvents:Array<String> = [];

		for (event in sys.FileSystem.readDirectory('assets/data/events'))
		{
			if (event.contains('.'))
			{
				event = event.substring(0, event.indexOf('.', 0));
				loadedEvents.set(event, new FeatherModule(AssetHelper.grabAsset('$event', MODULE, 'data/events')));
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
