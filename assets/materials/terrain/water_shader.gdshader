shader_type spatial;

uniform sampler2D water_normal;
uniform vec3 water_colour : source_color;
uniform float time_scale : hint_range(0.0, 0.1, 0.01);
// Water parameters
uniform float water_translucency_depth : hint_range(0.0, 2.0, 0.1);
uniform float transparency_influence : hint_range(0.0, 1.0, 0.1);
uniform float depth_falloff : hint_range(0.0, 20.0, 0.1) = 3.0;

// Read screen and depth textures
uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D depth_texture : hint_depth_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Adjust time scale
	float time = TIME * time_scale;
	
	// Calculate water depth
	vec4 world = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, texture(depth_texture, SCREEN_UV).r, 1.0);
	world.xyz /= world.w;
	float depth_blend = smoothstep(world.z + water_translucency_depth, world.z, VERTEX.z);
	depth_blend = depth_blend * exp(-depth_falloff);
	ALBEDO = mix(texture(screen_texture, SCREEN_UV).rgb * depth_blend, water_colour, 1.0-transparency_influence);
	//ALBEDO = vec3(depth_blend);
	
	//ALBEDO = texture(screen_texture, SCREEN_UV).rgb;
	ROUGHNESS = 0.15;
	NORMAL_MAP = texture(water_normal, (UV * 10.0) + vec2(time)).rgb * 0.5 + texture(water_normal, (UV * 10.0) + vec2(-time, time)).rgb * 0.5;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
