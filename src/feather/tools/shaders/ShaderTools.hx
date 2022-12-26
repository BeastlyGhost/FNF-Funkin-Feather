package feather.tools.shaders;

class ShaderTools {
	public static function initAUCS():AUColorSwap {
		var swap:AUColorSwap = new AUColorSwap();

		swap.red = 0xFFFFFFFF;
		swap.blue = 0xFFFFFFFF;
		swap.green = 0xFFFFFFFF;

		return swap;
	}
}
