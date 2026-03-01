shader_type spatial;

render_mode unshaded;

#define NUM_LAYERS 1

#define NUM_DIRECTIONAL_MASKS 0
#define NUM_POSITIONAL_MASKS 0
#define NUM_VERTEX_COLOR_MASKS 0

#define NUM_UV_TRANSFORMS 0
#define NUM_UV_MAPS 0
#define NUM_TRIPLANAR_MAPS 0

#define NUM_TEXTURES 0

#define NUM_VECTOR2_DECOMPOSITIONS 0
#define NUM_VECTOR3_DECOMPOSITIONS 0
#define NUM_VECTOR4_DECOMPOSITIONS 0

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

float get_directional_mask(int mask_id, vec3 local_normal, vec3 global_normal) {
	
	vec3 normal = local_normal * float(directional_mask_spaces[mask_id] == 0) + global_normal * float(directional_mask_spaces[mask_id] == 1);
	
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

float get_positional_mask(int mask_id, vec3 local_pos, vec3 global_pos) {
	float positional_mask_value;
	float positional_mask_max = positional_mask_maximums[mask_id];
	float positional_mask_min = positional_mask_minimums[mask_id];

	vec3 v_position = (float(positional_mask_spaces[mask_id] == 0) * local_v_position) + (float(positional_mask_spaces[mask_id] == 1) * global_v_position);

	switch (get_layer_positional_mask_axis(layer)) {
			case 0:
				positional_mask_value = clamp(1.0/(positional_mask_max - positional_mask_min) * v_position.x + (1.0 - 1.0/(positional_mask_max - positional_mask_min) * positional_mask_max), 0.002, 0.998);
			case 1:
				positional_mask_value = clamp(1.0/(positional_mask_max - positional_mask_min) * v_position.y + (1.0 - 1.0/(positional_mask_max - positional_mask_min) * positional_mask_max), 0.002, 0.998);
			case 2:
				positional_mask_value = clamp(1.0/(positional_mask_max - positional_mask_min) * v_position.z + (1.0 - 1.0/(positional_mask_max - positional_mask_min) * positional_mask_max), 0.002, 0.998);
		}
}
#endif

#if NUM_VERTEX_COLOR_MASKS > 0
uniform int[NUM_VERTEX_COLOR_MASKS] vertex_color_mask_modes;
uniform vec3[NUM_VERTEX_COLOR_MASKS] vertex_color_custom_colors;
uniform float[NUM_VERTEX_COLOR_MASKS] vertex_color_custom_margins;

float get_vertex_color_mask(int mask_id, vec3 vertex_color) {
	return 0.0
}
#endif




#if NUM_UV_TRANSFORMS > 0
uniform vec2[NUM_UV_TRANSFORMS] uv_transform_scales;
uniform vec2[NUM_UV_TRANSFORMS] uv_transform_offsets;
#endif

#if NUM_UV_MAPS > 0
uniform int[NUM_UV_MAPS] uv_map_sources;
#endif

#if NUM_TRIPLANAR_MAPS > 0
uniform int[NUM_TRIPLANAR_MAPS] triplanar_map_spaces;

vec2 get_triplanar_uv(int uv_index, vec3 local_normal, vec3 global_normal, vec3 local_pos, vec3 global_pos) {
	vec3 normal = local_normal * float(triplanar_map_spaces[uv_index] == 0) + global_normal * float(triplanar_map_spaces[uv_index] == 1);
	normal = abs(normal);
	
	vec3 pos = local_pos * float(triplanar_map_spaces[uv_index] == 0) + global_pos * float(triplanar_map_spaces[uv_index] == 1);
	
	int direction = 0;
	//0=x, 1=y, 2=z
	float largest_comp = 0.0;

	if (normal.x > largest_comp) {
		direction = 0;
		largest_comp = normal.x;
	}
	if (normal.y > largest_comp) {
		direction = 1;
		largest_comp = normal.y;
	}
	if (normal.z > largest_comp) {
		direction = 2;
	}

	return vec2(pos.z, pos.y) * float(direction == 0) + vec2(pos.x, pos.z) * float(direction == 1) + vec2(pos.x, pos.y) * float(direction == 2);

}
#endif




#if NUM_TEXTURES > 0
uniform sampler2D[NUM_TEXTURES] textures : source_color;
#endif



#if NUM_VECTOR2_DECOMPOSITIONS > 0
uniform int[NUM_VECTOR2_DECOMPOSITIONS] vector2_decomposition_output_channels;

float decompose_vector2(int decomposition_id, vec2 value) {
	return (value.x * float(vector2_decomposition_output_channels[decomposition_id] == 0) + value.y * float(vector2_decomposition_output_channels[decomposition_id] == 1) + length(value) * float(vector2_decomposition_output_channels[decomposition_id] == 2))
}
#endif

#if NUM_VECTOR3_DECOMPOSITIONS > 0
uniform int[NUM_VECTOR3_DECOMPOSITIONS] vector3_decomposition_output_channels;

float decompose_vector3(int decomposition_id, vec3 value) {
	return (value.x * float(vector3_decomposition_output_channels[decomposition_id] == 0) + value.y * float(vector3_decomposition_output_channels[decomposition_id] == 1) + value.z * float(vector3_decomposition_output_channels[decomposition_id] == 2) + length(value) * float(vector3_decomposition_output_channels[decomposition_id] == 3))
}
#endif

#if NUM_VECTOR4_DECOMPOSITIONS > 0
uniform int[NUM_VECTOR4_DECOMPOSITIONS] vector4_decomposition_output_channels;

float decompose_vector3(int decomposition_id, vec4 value) {
	return (value.x * float(vector4_decomposition_output_channels[decomposition_id] == 0) + value.y * float(vector4_decomposition_output_channels[decomposition_id] == 1) + value.z * float(vector4_decomposition_output_channels[decomposition_id] == 2) + value.w * float(vector4_decomposition_output_channels[decomposition_id] == 3) + length(value) * float(vector4_decomposition_output_channels[decomposition_id] == 4))
}
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


vec4 get_layer_albedo(int layer_index, vec2 uv, vec2 uv2) {
	//get_albedo
	return vec4(0.0);
}

vec3 get_layer_normal(int layer_index) {
	//get_normal
	return vec3(0.0);
}

float get_layer_roughness(int layer_index) {
	//get_roughness
	return 0.0;
}

float get_layer_metallic(int layer_index) {
	//get_metallic
	return 0.0;
}


void vertex() {
	local_vertex_normal = NORMAL.rgb;
	global_vertex_normal = local_vertex_normal * MODEL_NORMAL_MATRIX;
	local_vertex_pos = VERTEX.xyz;
	global_vertex_pos = (vec4(local_vertex_pos, 1.0) * MODEL_MATRIX).xyz;
	global_camera_pos = CAMERA_POSITION_WORLD;
}

void fragment() {
	
	vec3 albedo_mix;
	vec3 normal_mix;
	float roughness_mix;
	float metallic_mix;
	
	int starting_index = 0;
	int process_index = 0;
	
	float[NUM_LAYERS] layer_masks;
	
	//fragment
	
	for (int i = starting_index; i < NUM_LAYERS; i++) {
		if (process_index == 0) {
			albedo_mix = get_layer_albedo(i, UV, UV2).rgb;
			normal_mix = get_layer_normal(i);
			roughness_mix = get_layer_roughness(i);
			metallic_mix = get_layer_metallic(i);
		}
		else {
			vec4 albedo = get_layer_albedo(i, UV, UV2);
			albedo_mix = mix(albedo_mix, albedo.rgb, layer_masks[i] * albedo.a);
			
			normal_mix = mix(normal_mix, get_layer_normal(i), layer_masks[i]);
			roughness_mix = mix(roughness_mix, get_layer_roughness(i), layer_masks[i]);
			metallic_mix = mix(metallic_mix, get_layer_metallic(i), layer_masks[i]);
		}
		
		process_index += 1;
	}
	
	ALBEDO = albedo_mix;
	//NORMAL = normal_mix;
	ROUGHNESS = roughness_mix;
	METALLIC = metallic_mix;
	
}
