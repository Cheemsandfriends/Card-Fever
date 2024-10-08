package;
import flixel.util.FlxColor;
import flixel.system.FlxAssets.FlxShader;

class GradientStuff
{
	public var color1(default, set):FlxColor;
	public var color2(default, set):FlxColor;
	public var vertical(default, set):Bool;
	public var shader:GradientShader;
	public function new(color1:FlxColor, color2:FlxColor, vertical:Bool = false)
	{
		shader = new GradientShader();

		this.color1 = color1;
		this.color2 = color2;
		this.vertical = vertical;
	}

	function set_color1(value:FlxColor)
	{
		shader.col1.value = [value.redFloat, value.greenFloat, value.blueFloat, value.alphaFloat];
		return value;
	}
	function set_color2(value:FlxColor)
	{
		shader.col2.value = [value.redFloat, value.greenFloat, value.blueFloat, value.alphaFloat];
		return value;
	}
	function set_vertical(value:Bool)
	{
		shader.vertical.value = [value];
		return value;
	}
}
class GradientShader extends FlxShader
{
	@:glFragmentSource("
    #pragma header
		uniform bool vertical;
        uniform vec4 col1;
        uniform vec4 col2;
		
        void main()
        {	
            gl_FragColor = mix(col1, col2, (vertical) ? 1. - openfl_TextureCoordv.y : openfl_TextureCoordv.x);
        }
    ")
	public function new()
	{
		super();
	}
}