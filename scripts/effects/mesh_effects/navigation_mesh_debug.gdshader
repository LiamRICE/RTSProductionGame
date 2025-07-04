shader_type spatial;

uniform vec4 fill_color : source_color = vec4(0.1, 0.6, 1.0, 0.4); // Transparent blue
uniform vec4 wire_color : source_color = vec4(0.2, 0.9, 1.0, 1); // Cyan wireframe
uniform float line_width = 1.0;

varying vec3 barycentric;

void vertex() {
    // Use gl_VertexID to assign barycentric coordinates (for wireframe detection)
    int vid = VERTEX_ID % 3;
    if (vid == 0) {
        barycentric = vec3(1, 0, 0);
    } else if (vid == 1) {
        barycentric = vec3(0, 1, 0);
    } else {
        barycentric = vec3(0, 0, 1);
    }
}

float edge_factor(float width) {
    vec3 d = fwidth(barycentric);
    vec3 a3 = smoothstep(vec3(0.0), d * width, barycentric);
    return min(min(a3.x, a3.y), a3.z);
}

void fragment() {
    float edge = edge_factor(line_width);
    
    // Blend between fill and wire colors
    vec4 base = fill_color;
    base.rgb = mix(wire_color.rgb, base.rgb, edge);
    base.a = mix(wire_color.a, base.a, edge);

    ALBEDO = base.rgb;
    ALPHA = base.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
