shader_type canvas_item;

uniform sampler2D light;
//uniform vec2 offset_pos;
//
//const vec2 screen_grid_size = 1.0 / vec2(35.5,20);
//
//void fragment() {
	//vec2 snapped_uv = SCREEN_UV / screen_grid_size + vec2(1.75,8.5) + offset_pos;
	//vec2 sample_uv = (floor(snapped_uv) + 0.5) * screen_grid_size;
	//COLOR = texture(light,sample_uv * vec2(0.9,0.5)) * texture(TEXTURE,UV);
//}
void fragment() {
	COLOR *= clamp(texture(light,SCREEN_UV),0.0,1.0); //* texture(TEXTURE,UV) * modulate;
}