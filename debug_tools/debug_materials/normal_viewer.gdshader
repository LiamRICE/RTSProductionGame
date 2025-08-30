shader_type spatial;

uniform bool normal = true;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (normal){
		ALBEDO = NORMAL;
	}else{
		ALBEDO = COLOR.rgb;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
