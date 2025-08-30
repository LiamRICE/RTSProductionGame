shader_type spatial;

uniform sampler2D splatmap;
// Grass textures
uniform sampler2D grass_diff;
uniform sampler2D grass_arm;
uniform sampler2D grass_normal;
// Road textures
uniform sampler2D road_diff;
uniform sampler2D road_arm;
uniform sampler2D road_normal;
// City textures
uniform sampler2D city_diff;
uniform sampler2D city_arm;
uniform sampler2D city_normal;
// Sand textures
uniform sampler2D sand_diff;
uniform sampler2D sand_arm;
uniform sampler2D sand_normal;
//
const float texture_scale = 10.0;
global uniform vec2 world_size;
instance uniform vec2 chunk_position;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 loc = texture(splatmap, (UV + chunk_position) / world_size);
	// Albedo
	ALBEDO = texture(road_diff, UV * texture_scale).rgb * loc.r + texture(city_diff, UV * texture_scale).rgb * (loc.g - loc.r) + vec3(0.0, 0.0, 1.0) * loc.b + texture(grass_diff, UV * texture_scale).rgb * loc.a;
	//ALBEDO = vec3(1.0,0.0,0.0) * loc.r + vec3(0.0,1.0,0.0) * (loc.g - loc.r) + vec3(0.0, 0.0, 1.0) * loc.b + vec3(0.0,0.0,1.0) * loc.a;
	// Calculate ARM
	vec3 arm = texture(road_arm, UV * texture_scale).rgb * loc.r + texture(city_arm, UV * texture_scale).rgb * (loc.g - loc.r) + vec3(1.0, 0.0, 0.0) * loc.b + texture(grass_arm, UV * texture_scale).rgb * loc.a;
	// Ambient Occlusion
	AO = arm.r;
	// Roughness
	ROUGHNESS = arm.g;
	// Metallic
	METALLIC = arm.b;
	// Normal mapping
	NORMAL_MAP = texture(road_normal, UV * texture_scale).rgb * loc.r + texture(city_normal, UV * texture_scale).rgb * (loc.g - loc.r) + texture(sand_normal, UV * texture_scale).rgb * loc.b + texture(grass_normal, UV * texture_scale).rgb * loc.a;
	//NORMAL_MAP = texture(grass_normal, UV * texture_scale).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
