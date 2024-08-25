shader_type canvas_item;


uniform vec4 shine_color = vec4(1.0);
uniform float shine_progress : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float shine_size : hint_range(0.01, 1.0, 0.01) = 0.1;
uniform float shine_angle : hint_range(0.0, 90, 0.1) = 45.0;

float scale(float value, float inMin, float inMax, float outMin, float outMax) {
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

void fragment() {
	float size_x = float(textureSize(TEXTURE, 0).x);
	float size_y = float(textureSize(TEXTURE, 0).y);
	COLOR = texture(TEXTURE, UV);
	vec2 UVr = vec2(floor(UV.x*size_x)/size_x, floor(UV.y*size_y)/size_y);
	float slope = tan(radians(shine_angle));
	float progress = scale(shine_progress, 0.0, 1.0, -1.0 - shine_size - shine_size * slope, 1.0 * slope);
	float shine = step(slope * UVr.x - UVr.y, progress + shine_size + shine_size * slope) - step(slope * UVr.x - UVr.y, progress);
	COLOR.rgb = mix(COLOR.rgb, shine_color.rgb, shine * shine_color.a);
}