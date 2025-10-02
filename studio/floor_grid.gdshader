shader_type spatial;

render_mode depth_prepass_alpha;

uniform sampler2D grid_texture;
uniform float transparency : hint_range(0.0, 1.0, 0.01) = 1.0;

varying vec3 global_vertex_pos;

void vertex() {
	global_vertex_pos = (vec4(VERTEX.xyz, 1.0) * MODEL_MATRIX).xyz;
}

float get_radial_fac(vec2 uv_point) {
	return 1.0 - (distance(uv_point, vec2(0.5, 0.5)) * 2.0);
}

void fragment() {
	vec4 tex = texture(grid_texture, vec2(global_vertex_pos.x, global_vertex_pos.z));
	ALBEDO = tex.rgb;
	ALPHA = get_radial_fac(UV) * tex.a * transparency;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
