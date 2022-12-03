package funkin.backend.data;

class OptionsContainer
{
	public static var optionsListMap:Map<String, Array<String>> = [
		"gameplay" => ["Downscroll", "Ghost Tapping", "Show Grades", "Safe Frames"],
		"accessibility" => ["Auto Pause", "Anti Aliasing", "Flashing Lights"],
		"debugging" => ["Framerate Cap", "Show Framerate", "Show Memory", "Show Debug"],
		"custom settings" => [],
	];

	public static function getList(listName:String)
		return optionsListMap.get(listName);
}
