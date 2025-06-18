shader_type spatial;
render_mode unshaded, world_vertex_coords;

instance uniform vec3 start = vec3(0,0,0);
instance uniform vec3 end = vec3(0,0,0);
instance uniform vec4 colour = vec4(1, 1, 1, 0);

void vertex() {
	// Called for every vertex the material is visible on.
	if (VERTEX_ID == 0){
		VERTEX = start + vec3(0.3);
	}else{
		VERTEX = end + vec3(0.3);
	}
}

void fragment() {
	ALBEDO = colour.rgb;
	ALPHA = colour.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
