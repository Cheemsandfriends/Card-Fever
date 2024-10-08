package;

import flixel.system.FlxAssets.FlxShader;

class Dithering {
    public var shader(default, null):DitheringShader = new DitheringShader();
	public var pixel_factor(default, set):Float = 1280;
	public var color_factor(default, set):Float = 8.5;

    public function new()
    {
        shader.COLOR_FACTOR.value = [color_factor];
        shader.PIXEL_FACTOR.value = [pixel_factor];
    }

    public function set_pixel_factor(value:Float):Float {
        pixel_factor = value;
        shader.PIXEL_FACTOR.value = [pixel_factor];
        return pixel_factor;
    }

    public function set_color_factor(value:Float):Float{
        color_factor = value;
        shader.COLOR_FACTOR.value = [color_factor];
        return color_factor;
    }
}
class DitheringShader extends FlxShader
{
	@:glFragmentSource('
	//SHADERTOY PORT FIX
	#pragma header

	//****MAKE SURE TO remove the parameters from mainImage.
	
    uniform float PIXEL_FACTOR; // Lower num - bigger pixels
    uniform float COLOR_FACTOR;   // Higher num - higher colors quality

    float getMatVal(vec2 st)
    {
        int xS = int(st.x);
        int yS = int(st.y);
        if (xS == 0)
        {
            if (yS == 0)
                return -4.0;
            if (yS == 1)
                return 0.0;
            if (yS == 2)
                return -3.0;
            if (yS == 3)
                return 1.0;
        }
        if (xS == 1)
        {
            if (yS == 0)
                return 2.0;
            if (yS == 1)
                return -2.0;
            if (yS == 2)
                return 3.0;
            if (yS == 3)
                return -1.0;
        }
        if (xS == 0)
        {
            if (yS == 0)
                return -3.0;
            if (yS == 1)
                return 1.0;
            if (yS == 2)
                return -4.0;
            if (yS == 3)
                return 0.0;
        }
        if (xS == 0)
        {
            if (yS == 0)
                return 3.0;
            if (yS == 1)
                return -1.0;
            if (yS == 2)
                return 2.0;
            if (yS == 3)
                return -2.0;
        }

        return 0.0;
    }

    void main()
    {                  
        // Reduce pixels            
        vec2 size = PIXEL_FACTOR * openfl_TextureSize.xy/openfl_TextureSize.x;
        vec2 coor = floor( openfl_TextureCoordv * size) ;
        vec2 uv = coor / size;
                    
        // Get source color
        vec4 img = flixel_texture2D(bitmap, uv);
        vec3 col = img.xyz;
        // Dither
        col += (getMatVal(vec2(floor( mod(coor.x, 4.0)), floor(mod(coor.y, 4.0 ) ))) * 0.005); // last number is dithering strength

        // Reduce colors    
        col = floor(col * COLOR_FACTOR) / COLOR_FACTOR;    
    
        // Output to screen
        gl_FragColor = vec4(col, img.a);
    }
')

	public function new()
	{
		super();
	}
}