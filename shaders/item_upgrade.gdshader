shader_type canvas_item;

uniform vec4 bottom_color: source_color;
uniform vec4 top_color: source_color;

uniform float wave_amp: hint_range(0.0, 0.5);
uniform float wave_size: hint_range(1.0, 10.0);
uniform float wave_time_mul: hint_range(0.1, 2.0);

uniform int total_phases: hint_range(2, 600, 1);

uniform bool useShine = false;


float rand(float n){return fract(sin(n) * 43758.5453123);}


float noise(float p){
	float fl = floor(p);
  float fc = fract(p);
	return mix(rand(fl), rand(fl + 1.0), fc);
}


float fmod(float x, float y) {
	return x - floor(x / y) * y;
}


vec4 lerp(vec4 a, vec4 b, float w) {
	return a + w * (b - a);
}


void fragment() {
	if (useShine) {
		float t = float(total_phases);
		float effective_wave_amp = min(wave_amp, 0.5 / t);
		float d = fmod(UV.y, 1.0 / t);
		float i = floor(UV.y * t);
		float vi = floor(UV.y * t + t * effective_wave_amp);
		float s = effective_wave_amp * sin((UV.x + TIME * max(1.0 / t, noise(vi)) * wave_time_mul * vi / t) * 2.0 * PI * wave_size);

		if (d < s) i--;
		if (d > s + 1.0 / t) i++;
		i = clamp(i, 0.0, t - 1.0);

		vec4 setColor = lerp(top_color, bottom_color, i / (t - 1.0));

		//COLOR = texture(TEXTURE,UV) * setColor;
		COLOR = mix(texture(TEXTURE,UV),setColor,setColor.a) * vec4(1.0,1.0,1.0,texture(TEXTURE,UV).a);
	}
}