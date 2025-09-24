shader_type spatial;

// Debug parameters
uniform bool debug_mode = false;
uniform bool view_snow_mask = false;
uniform bool view_cliff_mask = false;
uniform bool view_sand_mask = false;
// Parameters
uniform float large_noise_influence : hint_range(0.0, 1.0, 0.05) = 0.2;
uniform float cliff_amount : hint_range(0.0, 1.0, 0.01) = 0.3;
uniform float cliff_exponent : hint_range(0.1, 10.0, 0.05) = 2.0;
uniform float snow_threshold : hint_range(0.0, 1.0, 0.01) = 0.8;
uniform float snow_falloff : hint_range(0.0, 0.3, 0.01) = 0.1;
uniform float snow_randomisation_scale : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float sand_threshold : hint_range(0.0, 1.0, 0.01) = 0.13;
uniform float sand_falloff : hint_range(0.0, 0.3, 0.01) = 0.03;
uniform float sand_randomisation_scale : hint_range(0.0, 1.0, 0.01) = 0.3;
// Control Textures
uniform sampler2D noise_map;
uniform sampler2D large_noise;
uniform sampler2D color_gradient;
// Grass textures
uniform sampler2D grass_col;
uniform sampler2D grass_arm;
uniform sampler2D grass_normal;
// Rock textures
uniform sampler2D rock_col;
uniform sampler2D rock_arm;
uniform sampler2D rock_normal;
// Sand textures
uniform sampler2D sand_col;
uniform sampler2D sand_arm;
uniform sampler2D sand_normal;
// Chunk parameters
const float texture_scale = 20.0;
global uniform vec2 inv_world_size;
global uniform float inv_world_max_height;
instance uniform vec2 chunk_position;

// Fragment variables
varying float world_height;
varying float world_slope;

void vertex() {
	// Called for every vertex the material is visible on.
	world_height = (MODEL_MATRIX * vec4(VERTEX, 1.0)).y * inv_world_max_height;
	world_slope = 1.0 - NORMAL.y;
}

void fragment() {
	// Calculate the current uv position in global UV coordinates
	vec2 uv = (UV + chunk_position) * inv_world_size * texture_scale;
	float noise_map_value = texture(noise_map, UV * texture_scale).r;
	float large_noise_value = texture(large_noise, UV).r;
	
	// Calculate texture masks
	float cliff_mask = smoothstep(0.0, 1.0 - cliff_amount, pow(world_slope, cliff_exponent));
	float snow_mask = smoothstep(snow_threshold - snow_falloff, snow_threshold, world_height + noise_map_value * inv_world_max_height * snow_randomisation_scale + large_noise_value * 0.1) * (1.0 - cliff_mask);
	float sand_mask = smoothstep(sand_threshold + sand_falloff, sand_threshold, world_height + noise_map_value * inv_world_max_height * sand_randomisation_scale);
	
	// Debug view of calculated texture masks.
	// TODO - Delete in final project
	if(debug_mode){
		vec3 albedo = vec3(0.0);
		if(view_snow_mask){
			albedo.r = snow_mask;
		}if(view_cliff_mask){
			albedo.g = cliff_mask;
		}if(view_sand_mask){
			albedo.b = sand_mask;
		}
		ALBEDO = albedo;
	}else{
		// Texture following the masks with the following priority : Snow > Cliff > Sand > Grass
		ALBEDO = (texture(sand_col, uv).rgb * sand_mask + texture(rock_col, uv).rgb * cliff_mask + vec3(1.0) * snow_mask + texture(grass_col, uv).rgb * (1.0 - (sand_mask + cliff_mask + snow_mask))) * (1.0 - texture(large_noise, (UV + chunk_position) * inv_world_size).rgb * large_noise_influence);
		NORMAL_MAP = (texture(sand_normal, uv).rgb * sand_mask + texture(rock_normal, uv).rgb * cliff_mask + vec3(0.0, 0.0, 1.0) * snow_mask + texture(grass_normal, uv).rgb * (1.0 - (sand_mask + cliff_mask + snow_mask))) * 0.2;
		vec3 arm = texture(sand_arm, uv).rgb * sand_mask + texture(rock_arm, uv).rgb * cliff_mask + vec3(1.0, 0.2, 0.0) * snow_mask + texture(grass_arm, uv).rgb * (1.0 - (sand_mask + cliff_mask + snow_mask));
		AO = arm.r;
		ROUGHNESS = arm.g;
		METALLIC = arm.b;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
