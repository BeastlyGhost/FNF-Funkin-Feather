package feather.assets;

import sys.FileSystem;

typedef GroupForm = {
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
class AssetGroup {
	/**
		Specifies the DEFAULT Asset Group
	**/
	public static var defaultGroup:String = 'feather';

	/**
		Stores groups that will be taken into account while searching for assets
	**/
	public static var allGroups:Array<String> = [];

	/**
		Active groups that are enabled by the user
	**/
	public static var activeGroups:Array<String> = [];

	/**
		Current Active Group
	**/
	public static var activeGroup:String = null;

	/**
		Stores folder names that should be excluded when searching for groups
	**/
	public static var groupExclusions:Array<String> = ['data', 'images', 'music', 'scripts', 'sounds'];

	public var groupData:Map<String, GroupForm>;

	public function new():Void {
		// first grab the groups for the assets folder
		storeGroups();
	}

	public function storeGroups():Void {
		var groupsTemp:Array<String> = [];

		for (dir in FileSystem.readDirectory("assets"))
			if (dir != null && !dir.contains('.') && !groupExclusions.contains(dir) && !groupsTemp.contains(dir))
				groupsTemp.push(dir);

		groupsTemp.sort(function(group1, group2) return Reflect.compare(group1.toLowerCase(), group2.toLowerCase()));

		for (group in groupsTemp) {
			if (!allGroups.contains(group))
				allGroups.push(group);
		}

		// return groupsTemp;
	}

	/**
		Returns all the groups from within the assets folder
		@param file the file that we should look for
		@param type the file type, for getting the extension
		@param force whether to skip the system checks and force a group to be returned
	**/
	public function getFromDirs(file:String, type:AssetType, ?force:Bool):String {
		// loadGroupData();

		var chosenGroup:Array<String> = (activeGroups.length > 0 ? activeGroups : allGroups);

		// return null if there's no groups at all
		if (chosenGroup.length < 0)
			return null;

		for (e in 0...chosenGroup.length) {
			var groupReturn:String = null;

			/**
				System Checks, Check if the Specified File exists
				within the asset folders for every group

				WHAT THIS DOES:
				|	first, it checks on your active group,
				|	your active group should be the one set by you
				|	using the group manager menu or the freeplay menu

				|	if it fails, it checks for the default group
				|	the default group is a hardcoded value
				|	used to specify a master group of sorts

				|	if the default group check fails
				|	then, it checks on every group
				|	this check should never fail in most cases
				|	it almost always ends up returning a file at the end
				--------------------------------------------------------

				if each of these return null, the group folder shouldn't be used
				instead, use the main assets folder

				TODO: remake this system probably, it's pretty flawled as it is currently
			**/

			if (force)
				return chosenGroup[e];

			if (checkExists(activeGroup, file, type))
				groupReturn = activeGroup;
			else if (checkExists(defaultGroup, file, type))
				groupReturn = defaultGroup;
			else if (checkExists(chosenGroup[e], file, type))
				groupReturn = chosenGroup[e];

			if (groupReturn != null)
				return groupReturn;
		}

		// else just return nothing
		return null;
	}

	public function checkExists(group:String, file:String, type:AssetType):Bool
		return FileSystem.exists(AssetHelper.getExtensions('assets/$group/$file', type));

	public function loadGroupData():Void {
		for (i in 0...allGroups.length) {
			if (FileSystem.exists(AssetHelper.grabAsset("group", YAML))) {
				try {
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
					throw('Group Data for ${allGroups[i]} could not be set.');
			} else {
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
	public function setActiveGroups():Void {
		for (group => data in groupData) {
			if (data == null)
				return;

			if (group != null && data != null) {
				if (data.enabled && !activeGroups.contains(group))
					activeGroups.push(group);
			}
		}
	}
}
