package feather;

/**
	String Tools for any type of String Expression
**/
class FeatherStrings
{
	/**
		Format Strings as a Title. Example: ``'world_machine' -> 'World Machine'``.
	**/
	inline public static function toTitle(str:String):String
	{
		var splits:Array<String> = str.toLowerCase().split(" ");

		for (i in 0...splits.length)
			splits[i] = splits[i].charAt(0).toUpperCase() + splits[i].substr(1);

		return splits.join(" ");
	}
}
