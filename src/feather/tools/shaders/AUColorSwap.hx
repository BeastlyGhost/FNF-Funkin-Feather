package feather.tools.shaders;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

/**
	Among Us Color Swap Shader for Notes
	@origin VS RetroSpecter v1.75

	https://github.com/TheRetroSpecter/VsRetro-Psych-Public/tree/main/source/shaders
**/
class AUColorSwap extends FlxShader {
	@:glFragmentHeader("uniform vec3 uRed;
	uniform vec3 uGreen;
	uniform vec3 uBlue;
	uniform float uApply;

	vec3 blendAdd(vec3 base, vec3 blend, vec3 blend2) {
		return min(base+blend+blend2,vec3(1.0));
	}

	vec4 flixel_texture2DExtra(sampler2D bitmap, vec2 coord) {
		vec4 color = texture2D(bitmap, coord);

	vec3 r = color.r * uRed;
	vec3 g = color.g * uGreen;
	vec3 b = color.b * uBlue;

	vec3 result = blendAdd(r, g, b);
	vec4 ares = vec4(result, color.a);
	color = mix(color, ares, uApply);

	if(!hasTransform){return color;}

	if(color.a == 0.0){return vec4(0.0, 0.0, 0.0, 0.0);}

	if(!hasColorTransform){return color * openfl_Alphav;}

	color = vec4(color.rgb / color.a, color.a);

	mat4 colorMultiplier = mat4(0);
	colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
	colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
	colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
	colorMultiplier[3][3] = openfl_ColorMultiplierv.w;

	color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);

	if(color.a > 0.0){
		return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
	}
	return vec4(0.0, 0.0, 0.0, 0.0);
	}")
	@:glFragmentSource('
	#pragma header

	uniform vec3 uHsv; // [h, s, v]

	vec3 rgb2hsv(vec3 c) {
		vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
		vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
		vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

		float d = q.x - min(q.w, q.y);
		float e = 1.0e-10;
		return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	}

	vec3 hsv2rgb(vec3 c) {
		vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
		vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
		return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
	}

	void main() {
		vec4 color = flixel_texture2DExtra(bitmap, openfl_TextureCoordv);

		vec3 swagColor = rgb2hsv(color.rgb);

		swagColor.xy += uHsv.xy;
		swagColor[2] = swagColor[2] * (1.0 + uHsv[2]);

		swagColor[1] = clamp(swagColor[1], 0.0, 1.0);

		gl_FragColor = vec4(hsv2rgb(swagColor), color.a);
	}')
	public function new() {
		super();

		this.uRed.value = [1, 0, 0];
		this.uGreen.value = [0, 1, 0];
		this.uBlue.value = [0, 0, 1];
		this.uHsv.value = [0, 0, 0];
		this.uApply.value = [1];
	}

	public var red(get, set):FlxColor;
	public var green(get, set):FlxColor;
	public var blue(get, set):FlxColor;

	public var hue(default, set):Float = 0;
	public var saturation(default, set):Float = 0;
	public var brightness(default, set):Float = 0;

	public var active(get, set):Bool;

	inline function set_active(value:Bool):Bool {
		this.uApply.value[0] = value ? 1 : 0;
		return value;
	}

	inline function get_active():Bool {
		var a = this.uApply.value[0];
		return (a == 0) ? false : true;
	}

	private function set_hue(value:Float):Float {
		this.uHsv.value[0] = value;
		return hue = value;
	}

	private function set_saturation(value:Float):Float {
		this.uHsv.value[1] = value;
		return saturation = value;
	}

	private function set_brightness(value:Float):Float {
		this.uHsv.value[2] = value;
		return brightness = value;
	}

	inline function set_red(value:FlxColor):FlxColor {
		this.uRed.value = toVec3(value);
		return value;
	}

	inline function get_red():FlxColor {
		var color = this.uRed.value;
		return FlxColor.fromRGBFloat(color[0], color[1], color[2]);
	}

	inline function set_green(value:FlxColor):FlxColor {
		this.uGreen.value = toVec3(value);
		return value;
	}

	inline function get_green():FlxColor {
		var color = this.uGreen.value;
		return FlxColor.fromRGBFloat(color[0], color[1], color[2]);
	}

	inline function set_blue(value:FlxColor):FlxColor {
		this.uBlue.value = toVec3(value);
		return value;
	}

	inline function get_blue():FlxColor {
		var color = this.uBlue.value;
		return FlxColor.fromRGBFloat(color[0], color[1], color[2]);
	}

	static function toVec3(color:FlxColor):Array<Float> {
		return [color.redFloat, color.greenFloat, color.blueFloat];
	}
}

class AUCSData {
	public var uRed:Array<Float> = [1, 0, 0];
	public var uGreen:Array<Float> = [0, 1, 0];
	public var uBlue:Array<Float> = [0, 0, 1];
	public var uHsv:Array<Float> = [0, 0, 0];
	public var uApply:Array<Float> = [1];

	public var red(get, set):FlxColor;
	public var green(get, set):FlxColor;
	public var blue(get, set):FlxColor;

	public var hue(default, set):Float = 0;
	public var saturation(default, set):Float = 0;
	public var brightness(default, set):Float = 0;

	public var active(get, set):Bool;

	inline function set_active(value:Bool):Bool {
		this.uApply[0] = value ? 1 : 0;
		return value;
	}

	inline function get_active():Bool {
		var a = this.uApply[0];
		return (a == 0) ? false : true;
	}

	private function set_hue(value:Float):Float {
		this.uHsv[0] = value;
		return hue = value;
	}

	private function set_saturation(value:Float):Float {
		this.uHsv[1] = value;
		return saturation = value;
	}

	private function set_brightness(value:Float):Float {
		this.uHsv[2] = value;
		return brightness = value;
	}

	inline function set_red(value:FlxColor):FlxColor {
		this.uRed = toVec3(value);
		return value;
	}

	inline function get_red():FlxColor {
		var color = this.uRed;
		return FlxColor.fromRGBFloat(color[0], color[1], color[2]);
	}

	inline function set_green(value:FlxColor):FlxColor {
		this.uGreen = toVec3(value);
		return value;
	}

	inline function get_green():FlxColor {
		var color = this.uGreen;
		return FlxColor.fromRGBFloat(color[0], color[1], color[2]);
	}

	inline function set_blue(value:FlxColor):FlxColor {
		this.uBlue = toVec3(value);
		return value;
	}

	inline function get_blue():FlxColor {
		var color = this.uBlue;
		return FlxColor.fromRGBFloat(color[0], color[1], color[2]);
	}

	static function toVec3(color:FlxColor):Array<Float> {
		return [color.redFloat, color.greenFloat, color.blueFloat];
	}
}
