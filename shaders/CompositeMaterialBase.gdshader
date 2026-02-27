shader_type spatial;

#define NUM_DIRECTIONAL_MASKS 0
#define NUM_POSITIONAL_MASKS 0
#define NUM_VERTEX_COLOR_MASKS 0

#define NUM_UV_MAPS 0
#define NUM_TRIPLANAR_MAPS 0

#define NUM_TEXTURES 0

#define NUM_INT_VALUES 0
#define NUM_FLOAT_VALUES 0
#define NUM_VECTOR2_VALUES 0
#define NUM_VECTOR3_VALUES 0
#define NUM_VECTOR4_VALUES 0


//end definitions


#if NUM_DIRECTIONAL_MASKS > 0
uniform vec3[NUM_DIRECTIONAL_MASKS] directional_mask_directions;
uniform int[NUM_DIRECTIONAL_MASKS] directional_mask_polarities;
uniform int[NUM_DIRECTIONAL_MASKS] directional_mask_spaces;

float get_directional_mask(int mask_id, vec3 normal) {
	switch (directional_mask_polarities[mask_id]) {
		case 0:
			return clamp(abs(dot(directional_mask_directions[mask_id], normal)), 0.0, 1.0);
		case 1:
			return clamp(dot(directional_mask_directions[mask_id], normal), 0.0, 1.0);
		case 2:
			return clamp(dot(directional_mask_directions[mask_id], normal) * -1.0, 0.0, 1.0);
	}
	return 0.0;
}
#endif

#if NUM_POSITIONAL_MASKS > 0:
uniform vec3[NUM_POSITIONAL_MASKS] positional_mask_axes;
uniform float[NUM_POSITIONAL_MASKS] positional_mask_minimums;
uniform float[NUM_POSITIONAL_MASKS] positional_mask_maximums;
uniform int[NUM_POSITIONAL_MASKS] positional_mask_spaces;

float get_positional_mask(int mask_id, vec3 position) {
	//todo: finish
}

#endif

#if NUM_VERTEX_COLOR_MASKS > 0
uniform int[NUM_VERTEX_COLOR_MASKS] vertex_color_mask_modes;
uniform vec3[NUM_VERTEX_COLOR_MASKS] vertex_color_custom_colors;
uniform float[NUM_VERTEX_COLOR_MASKS] vertex_color_custom_margins;
#endif




#if NUM_UV_MAPS > 0
uniform int[NUM_UV_MAPS] uv_map_sources;
#endif

#if NUM_TRIPLANAR_MAPS > 0
uniform int[NUM_TRIPLANAR_MAPS] triplanar_map_spaces;
#endif




#if NUM_TEXTURES > 0
uniform sampler2D[NUM_TEXTURES] textures : source_color;
#endif



#if NUM_INT_VALUES > 0
uniform int[NUM_INT_VALUES] int_values;
#endif

#if NUM_FLOAT_VALUES > 0
uniform float[NUM_FLOAT_VALUES] float_values;
#endif

#if NUM_VECTOR2_VALUES > 0
uniform vec2[NUM_VECTOR2_VALUES] vector2_values;
#endif

#if NUM_VECTOR3_VALUES > 0
uniform vec3[NUM_VECTOR3_VALUES] vector3_values;
#endif

#if NUM_VECTOR4_VALUES > 0
uniform vec4[NUM_VECTOR4_VALUES] vector4_values;
#endif



varying vec3 local_vertex_normal;
varying vec3 global_vertex_normal;
varying vec3 global_vertex_pos;
varying vec3 local_vertex_pos;
varying vec3 vertex_color;
varying vec3 global_camera_pos;

void vertex() {
	local_vertex_normal = NORMAL.rgb;
	global_vertex_normal = local_vertex_normal * MODEL_NORMAL_MATRIX;
	local_vertex_pos = VERTEX.xyz;
	global_vertex_pos = (vec4(local_vertex_pos, 1.0) * MODEL_MATRIX).xyz;
	global_camera_pos = CAMERA_POSITION_WORLD;
}

void fragment() {
	//fragment
}
