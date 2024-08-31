shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float size = 10.0;
void fragment() {
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);
	for (float x = -size; x < size; x++)
	{
		for (float y = -size; y < size; y++)
		{
			if (x*x + y*y > size*size){continue;}
			vec4 new_c = texture(screen_texture, SCREEN_UV+SCREEN_PIXEL_SIZE*vec2(x, y));
			if (length(new_c) >length(c)){
				c = new_c;
			}
		}
	}
	COLOR = c * vec4(0.75,0.75,0.75,1.0);
}