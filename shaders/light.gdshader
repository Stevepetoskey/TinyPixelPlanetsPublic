shader_type canvas_item;

uniform sampler2D light_map;
uniform sampler2D light_intensity_map;
uniform float max_range = 8.0;
uniform vec2 size = vec2(36.0,36.0);
uniform vec2 world_size = vec2(36.0,36.0);
uniform ivec2 position = ivec2(0,0);
uniform vec3 natural_light_color = vec3(1.0);
uniform float natural_light_intensity = 8.0;

void fragment() {
	vec2 screen_grid_size = 1.0 / size;
	vec2 world_grid_size = 1.0 / world_size;
	vec4 finalColor = vec4(vec3(0.0), 1.0);
	vec2 snapped_uv = floor(UV / screen_grid_size) + vec2(position);
	vec2 sample_uv = (snapped_uv + 0.5) * screen_grid_size;

	// Define the bounds for the loop
	float start_x = snapped_uv.x - max_range;
	float end_x = snapped_uv.x + max_range;
	float start_y = snapped_uv.y - max_range;
	float end_y = snapped_uv.y + max_range;

	// Adjust loop increment to avoid precision issues (use grid_size.x and grid_size.y directly)
	for (float x = start_x; x <= end_x; x += 1.0) {
		for (float y = start_y; y <= end_y; y += 1.0) {
			vec2 rayStart = vec2(x, y) + 0.5;
			vec2 rayStartUV = rayStart * world_grid_size; // Normalized for sampling

			// Make sure `rayStartUV` is within valid bounds
			 if (x >= -0.01 && x < world_size.x + 0.01 && y >= -0.01 && y < world_size.y + 0.01) {
				vec4 lightIntensitySample = texture(light_intensity_map, rayStartUV);

				if (lightIntensitySample.r > -0.001 && lightIntensitySample.a > -0.001) {
					float lightIntensity = lightIntensitySample.r * 255.0;
					vec3 light_color = texture(light_map, rayStartUV).rgb;
					if (lightIntensitySample.r > 0.9) {
						lightIntensity = natural_light_intensity;
						light_color = natural_light_color;
					}
					float dis = distance(snapped_uv + 0.5, rayStart);
					bool affected = true;
					bool inWall = false;
					float lastWallDis = -1.0;

					if (dis <= lightIntensity) {
						vec2 rayDir = normalize((snapped_uv + 0.5) - rayStart);
						vec2 rayUnitStep = vec2(sqrt(1.0 + (rayDir.y / rayDir.x) * (rayDir.y / rayDir.x)),sqrt(1.0 + (rayDir.x / rayDir.y) * (rayDir.x / rayDir.y)));
						ivec2 mapCheck = ivec2(int(x),int(y));
						vec2 rayLen1D;
						ivec2 vStep;

						if (rayDir.x < 0.0) {
							vStep.x = -1;
							rayLen1D.x = (rayStart.x - float(mapCheck.x)) * rayUnitStep.x;
						} else {
							vStep.x = 1;
							rayLen1D.x = (float(mapCheck.x + 1) - rayStart.x) * rayUnitStep.x;
						}
						if (rayDir.y < 0.0) {
							vStep.y = -1;
							rayLen1D.y = (rayStart.y - float(mapCheck.y)) * rayUnitStep.y;
						} else {
							vStep.y = 1;
							rayLen1D.y = (float(mapCheck.y + 1) - rayStart.y) * rayUnitStep.y;
						}
						float currentDistance = 0.0;
						int breakout = 0;
						while (currentDistance < dis && breakout < 100) {
							//walk
							breakout += 1;
							if (rayLen1D.x < rayLen1D.y) {
								mapCheck.x += vStep.x;
								currentDistance = rayLen1D.x;
								rayLen1D.x += rayUnitStep.x;
							} else {
								mapCheck.y += vStep.y;
								currentDistance = rayLen1D.y;
								rayLen1D.y += rayUnitStep.y;
							}
							if (mapCheck.x < 0 || mapCheck.x >= int(world_size.x) || mapCheck.y < 0 || mapCheck.y >= int(world_size.y)) {
								affected = false;
								break;
							}
							vec4 currentColor = texture(light_intensity_map,(vec2(mapCheck) + 0.5) * world_grid_size);
							if (currentColor.a > 0.5) {
								inWall = true;
								if (lastWallDis < -0.001) {
									lastWallDis = currentDistance;
								}
							} else if (currentColor.a <= 0.5 && inWall) {
								affected = false;
								break;
							}
							if (mapCheck.x == int(snapped_uv.x) && mapCheck.y == int(snapped_uv.y)) {
								break;
							}
						}
					} else {
						affected = false;
					}

					if (affected) {
						float light = 1.0 - (dis / lightIntensity);
						if (lastWallDis > -0.001) {
							float wallDistance = dis - lastWallDis;
							float lightWallLost = wallDistance * 1.5 - 1.5;
							light = 1.0 - ((dis + lightWallLost)/ lightIntensity);
						}

						//if (inWall) {
							//COLOR = vec4(1.0,0.0,0.0,1.0);
						//} else {
							//COLOR = vec4(0.0,1.0,0.0,1.0);
						//}
						finalColor.rgb = max(finalColor.rgb, light_color * light);
					}
				}
			}
		}
	}
	COLOR = clamp(finalColor,0.0,1.0);
}