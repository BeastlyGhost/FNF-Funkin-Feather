package data;

#if DISCORD_RPC
import discord_rpc.DiscordRpc;

/**
	Discord Client Wrapper class for the linc_discord-rpc library
	https://github.com/Aidan63/linc_discord-rpc
**/
class Discord
{
	inline public static function init():Void
	{
		DiscordRpc.start({
			clientID: "",
			onReady: ready,
			onError: catchError,
			onDisconnected: dc
		});
	}

	inline public static function ready():Void
	{
		DiscordRpc.presence({
			details: "",
			state: null,
			largeImageKey: 'logo',
			largeImageText: "Project Feather"
		});
	}

	inline static function catchError(_code:Int, _message:String):Void
		return trace('Error! $_code : $_message');

	inline static function dc(_code:Int, _message:String):Void
		return trace('Disconnected! $_code : $_message');

	inline public static function update(detailsMain:String = '', detailsSub:String = '', ?keyBig:String, ?keySmall:String, ?detailsBig:String,
			?detailsSmall:String, ?timeEnd:Float, startTime:Bool):Void
	{
		var timeNow:Float = (startTime ? Date.now().getTime() : 0);

		if (timeEnd > 0)
			timeEnd = timeNow + timeEnd;

		DiscordRpc.presence({
			details: detailsMain,
			state: detailsSub,
			largeImageKey: keyBig,
			smallImageKey: keySmall,
			largeImageText: detailsBig,
			smallImageText: detailsSmall,
			startTimestamp: Std.int(timeNow / 1000),
			endTimestamp: Std.int(timeEnd / 1000)
		});
	}

	inline public static function shutdownRPC()
		DiscordRpc.shutdown();
}
#else
class Discord {}
#end
