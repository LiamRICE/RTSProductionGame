shader_type spatial;
render_mode unshaded, depth_draw_always, shadows_disabled, cull_back;

uniform sampler2D heightmap : filter_nearest, repeat_disable;
uniform sampler2D fog_noise : filter_linear, repeat_enable;
uniform sampler2D fow_texture : repeat_disable;
uniform float fog_intensity = 0.25;

void vertex() {
	VERTEX.y = texture(heightmap, UV).r;
}

void fragment() {
	ALBEDO = vec3(0.0, 0.0, 0.0);
	//ALBEDO = texture(fow_texture, UV).rgb;
	ALPHA = (1.0 - texture(fow_texture, UV).r) * fog_intensity;// + (1.0 - texture(fog_noise, UV * vec2(1,1)).r * 0.5);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
