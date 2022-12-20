package feather.assets;

import sys.FileSystem;

typedef GroupForm =
{
    var index:Int; // for sorting
    var exclusions:Array<String>;
    var color:Int;
}

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
		Stores folder names that should be excluded when searching for groups
	**/
	public static var groupExclusions:Array<String> = ['data', 'images', 'music', 'scripts', 'sounds'];

    public function new():Void
    {
        // first grab the groups for the assets folder
        storeGroups();
    }

    public function storeGroups():Void
    {
        for (dir in FileSystem.readDirectory("assets"))
        {
            if (dir != null && !dir.contains('.') && !groupExclusions.contains(dir) && !allGroups.contains(dir))
                  allGroups.push(dir);
        }
    }

    public function getFromDirs(dir:String, type:AssetType):String
    {
        // return if there's no groups at all
        if (allGroups.length < 0)
            return null;

        for (e in 0...allGroups.length)
        {
            var newGroup:String = allGroups[e];
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
}
