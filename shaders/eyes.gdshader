shader_type canvas_item;

uniform vec4 eyeColor : source_color;
uniform vec4 hairColor : source_color;

void fragment() {
	COLOR = vec4(1,1,1,1);
	//vec4 currentColor = texture(TEXTURE,UV);
	//if (currentColor.a > 0.1 && currentColor.b > currentColor.g && currentColor.b > currentColor.r) {
		//COLOR = eyeColor - (1.0 - currentColor.b);
	//} else if (currentColor == vec4(1,0,0,1)) {
		//COLOR = hairColor - vec4(0.2,0.2,0.2,0);
	//} else {
		//COLOR = currentColor;
	//}
}
