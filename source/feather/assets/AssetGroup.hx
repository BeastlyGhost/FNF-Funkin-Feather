package feather.assets;

import sys.FileSystem;

typedef GroupForm =
{
	var desc:String;
	var enabled:Bool;
	var authors:Array<String>;
	var index:Int; // for sorting
	var color:Int;
}

/**
	Helper Class for Asset Groups
	@since INFDEV
**/
class AssetGroup
{
	/**
		Specifies the DEFAULT Asset Group
	**/
	public static var defaultGroup:String = 'funkin';

	/**
		Stores groups that will be taken into account while searching for assets
	**/
	public static var allGroups:Array<String> = [];

	/**
		Active groups that are enabled by the user
	**/
	public static var activeGroups:Array<String> = [];

	/**
		Stores folder names that should be excluded when searching for groups
	**/
	public static var groupExclusions:Array<String> = ['data', 'images', 'music', 'scripts', 'sounds'];

	public var groupData:Map<String, GroupForm>;

	public function new():Void
	{
		// first grab the groups for the assets folder
		storeGroups();
	}

	public function storeGroups():Void
	{
		var groupsTemp:Array<String> = [];

		for (dir in FileSystem.readDirectory("assets"))
			if (dir != null && !dir.contains('.') && !groupExclusions.contains(dir) && !groupsTemp.contains(dir))
				groupsTemp.push(dir);

		groupsTemp.sort(function(group1, group2) return Reflect.compare(group1.toLowerCase(), group2.toLowerCase()));

		for (group in groupsTemp)
		{
			if (!allGroups.contains(group))
				allGroups.push(group);
		}

		// return groupsTemp;
	}

	public function getFromDirs(dir:String, type:AssetType):String
	{
		// loadGroupData();

		var chosenGroup:Array<String> = (activeGroups.length > 0 ? activeGroups : allGroups);

		// return null if there's no groups at all
		if (chosenGroup.length < 0)
			return null;

		for (e in 0...chosenGroup.length)
		{
			var newGroup:String = chosenGroup[e];
			var assetLib:String = AssetHelper.getExtensions('assets/$newGroup/$dir', type);

			// check if the file exists on the group we want
			if (FileSystem.exists(assetLib))
			{
				// trace('Group is "$newGroup" for "$dir"');
				return newGroup;
			}
			else
			{
				// if it doesn't, check if it exists on the default one
				if (defaultGroup != null)
				{
					var originLib:String = AssetHelper.getExtensions('assets/$defaultGroup/$dir', type);
					if (FileSystem.exists(originLib))
						return defaultGroup;
				}
			}
		}

		// else just return nothing
		return null;
	}

	public function loadGroupData():Void
	{
		for (i in 0...allGroups.length)
		{
			if (FileSystem.exists(AssetHelper.grabAsset("group", YAML)))
			{
				try
				{
					var filePath:String = AssetHelper.grabAsset("group", YAML);
					var fileData:GroupForm = Yaml.read(filePath, yaml.Parser.options().useObjects());

					// conversion
					var finalData:GroupForm = {
						desc: fileData.desc,
						enabled: fileData.enabled,
						authors: fileData.authors,
						index: fileData.index,
						color: fileData.color
					};

					groupData.set(allGroups[i], finalData);
				}
				catch (e)
				{
					throw('Group Data for ${allGroups[i]} could not be set.');
				}
			}
			else
			{
				groupData.set(allGroups[i], {
					desc: null,
					enabled: true,
					authors: null,
					index: -1,
					color: 0xFFFFFFFF
				});
			}

			trace(groupData);

			setActiveGroups();
		}
	}

	/**
		Picks up all the Stored Data on `groupData`
		and sets the groups to the active groups array accordingly
	**/
	public function setActiveGroups():Void
	{
		for (group => data in groupData)
		{
			if (data == null)
				return;

			if (group != null && data != null)
			{
				if (data.enabled && !activeGroups.contains(group))
					activeGroups.push(group);
			}
		}
	}
}
