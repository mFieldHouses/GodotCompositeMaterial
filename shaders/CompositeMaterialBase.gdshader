shader_type spatial;

#define NUM_LAYERS 1

#define NUM_DIRECTIONAL_MASKS 0
#define NUM_POSITIONAL_MASKS 0
#define NUM_VERTEX_COLOR_MASKS 0
#define NUM_EFFECT_SHAPE_MASKS 0

#define NUM_UV_TRANSFORMS 0
#define NUM_UV_MAPS 0
#define NUM_TRIPLANAR_MAPS 0

#define NUM_COLOR_RAMPS 0
#define NUM_TEXTURES 0
#define NUM_NORMAL_MAP_TEXTURES 0

#define NUM_VECTOR2_DECOMPOSITIONS 0
#define NUM_VECTOR3_DECOMPOSITIONS 0
#define NUM_VECTOR4_DECOMPOSITIONS 0

#define NUM_INT_VALUES 0
#define NUM_FLOAT_VALUES 0
#define NUM_VECTOR2_VALUES 0
#define NUM_VECTOR3_VALUES 0
#define NUM_VECTOR4_VALUES 0

#define NUM_HSV_TRANSFORMS 0

//end definitions




struct uv_map {
	bool is_triplanar;
	
	vec2 uv1;
	float uv1_fac;
	
	vec2 uv2;
	float uv2_fac;
	
	vec2 uv3;
	float uv3_fac;
};





varying vec3 vertex_color;
varying vec3 local_vertex_normal;
varying vec3 global_vertex_normal;
varying vec3 hybrid_vertex_normal;
varying vec3 global_vertex_pos;
varying vec3 hybrid_vertex_pos;
varying vec3 local_vertex_pos;
varying vec3 global_camera_pos;

varying vec2 uv;
varying vec2 uv2;





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

float get_vertex_color_mask(int mask_id, vec3 vertex_col) {
	switch (vertex_color_mask_modes[mask_id]) {
		case 0:
			return vertex_col.r;
		case 1:
			return vertex_col.g;
		case 2:
			return vertex_col.b;
		default:
			return 0.0;
	}
}
#endif


#if NUM_EFFECT_SHAPE_MASKS > 0
uniform float[NUM_EFFECT_SHAPE_MASKS] effect_shape_mask_falloff_distances;
uniform int[NUM_EFFECT_SHAPE_MASKS] effect_shape_mask_layers;

global uniform sampler2DArray cpm_effect_shape_textures : filter_nearest;
global uniform int cpm_effect_shapes_num;

float get_effect_shape_mask(int mask_id, vec3 global_position) {
	
	vec3 effect_shape_positions[10];
	vec3 effect_shape_dimensions[10];
	
	for (int i = 0; i < 10; i++) {
		vec3 pos = (texture(cpm_effect_shape_textures, vec3((1.0/16384.0 * float(i)) + 0.5/16384.0, 0.5, 0)).rgb * 150000.0) - 75000.0;
		vec3 dimensions = (texture(cpm_effect_shape_textures, vec3((1.0/16384.0 * float(i)) + 0.5/16384.0, 0.5, 2)).rgb * 150000.0);
		
		effect_shape_positions[i] = pos;
		effect_shape_dimensions[i] = dimensions;
		
		if (pos == vec3(0.0)) {
			break;
		}
	}
	
	float distance_fac = 0.0;
	
	for (int i = 0; i < cpm_effect_shapes_num; i++) {
		distance_fac += clamp(1.0 - (distance(global_position, effect_shape_positions[i]) - effect_shape_dimensions[i].x) / effect_shape_mask_falloff_distances[mask_id], 0.0, 1.0);
	}
	
	return clamp(distance_fac, 0.0, 1.0);
}
#endif

#if NUM_UV_MAPS > 0
uniform int[NUM_UV_MAPS] uv_map_sources;

uv_map get_uv_map(int uv_index, uv_map uv1_in, uv_map uv2_in) {
	if (uv_map_sources[uv_index] == 0) {
		return uv1_in;
	}
	else {
		return uv2_in;
	}
}

#endif

#if NUM_TRIPLANAR_MAPS > 0
uniform int[NUM_TRIPLANAR_MAPS] triplanar_map_spaces;
uniform float[NUM_TRIPLANAR_MAPS] triplanar_map_blends;

uv_map get_triplanar_uv(int uv_index) {
	vec3 normal = local_vertex_normal * float(triplanar_map_spaces[uv_index] == 0) + global_vertex_normal * float(triplanar_map_spaces[uv_index] == 1) + hybrid_vertex_normal * float(triplanar_map_spaces[uv_index] == 2);
	vec3 pos = local_vertex_pos * float(triplanar_map_spaces[uv_index] == 0) + global_vertex_pos * float(triplanar_map_spaces[uv_index] == 1) + hybrid_vertex_pos * float(triplanar_map_spaces[uv_index] == 2);
	
	uv_map result;
	
	normal = normalize(normal);
	normal = pow(abs(normal), vec3(10.0 / clamp(triplanar_map_blends[uv_index], 0.063, 10.0)));
	normal = normal / (normal.x + normal.y + normal.z);
	
	result.uv1 = vec2(pos.z, pos.y);
	result.uv1_fac = normal.x;
	result.uv2 = vec2(pos.x, pos.z);
	result.uv2_fac = normal.y;
	result.uv3 = vec2(pos.x, pos.y);
	result.uv3_fac = normal.z;
	
	result.is_triplanar = true;
	
	return result;
}
#endif





#if NUM_TEXTURES > 0
uniform sampler2D[NUM_TEXTURES] nearest_neighbor_textures : source_color, filter_nearest_mipmap;
uniform sampler2D[NUM_TEXTURES] linear_textures : source_color, filter_linear_mipmap;
#endif

#if NUM_NORMAL_MAP_TEXTURES > 0
uniform float[NUM_NORMAL_MAP_TEXTURES] normal_map_scales;
uniform sampler2D[NUM_NORMAL_MAP_TEXTURES] normal_map_textures;
#endif



#if NUM_VECTOR2_DECOMPOSITIONS > 0
uniform int[NUM_VECTOR2_DECOMPOSITIONS] vector2_decomposition_output_channels;

float decompose_vector2(int decomposition_id, vec2 value) {
	return (value.x * float(vector2_decomposition_output_channels[decomposition_id] == 0) + value.y * float(vector2_decomposition_output_channels[decomposition_id] == 1));
}
#endif

#if NUM_VECTOR3_DECOMPOSITIONS > 0
uniform int[NUM_VECTOR3_DECOMPOSITIONS] vector3_decomposition_output_channels;

float decompose_vector3(int decomposition_id, vec3 value) {
	return (value.x * float(vector3_decomposition_output_channels[decomposition_id] == 0) + value.y * float(vector3_decomposition_output_channels[decomposition_id] == 1) + value.z * float(vector3_decomposition_output_channels[decomposition_id] == 2));
}
#endif

#if NUM_VECTOR4_DECOMPOSITIONS > 0
uniform int[NUM_VECTOR4_DECOMPOSITIONS] vector4_decomposition_output_channels;

float decompose_vector4(int decomposition_id, vec4 value) {
	return (value.x * float(vector4_decomposition_output_channels[decomposition_id] == 0) + value.y * float(vector4_decomposition_output_channels[decomposition_id] == 1) + value.z * float(vector4_decomposition_output_channels[decomposition_id] == 2) + value.w * float(vector4_decomposition_output_channels[decomposition_id] == 3));
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




#if NUM_HSV_TRANSFORMS > 0
uniform vec3[NUM_HSV_TRANSFORMS] hsv_transforms;

vec3 hue_to_rgb(float hue) {
    hue = fract(hue);
    float r = abs(hue * 6.0 - 3.0) - 1.0;
    float g = 2.0 - abs(hue * 6.0 - 2.0);
    float b = 2.0 - abs(hue * 6.0 - 4.0);
    vec3 rgb = vec3(r,g,b);
	rgb = clamp(rgb, vec3(0.0), vec3(1.0));
    return rgb;
}

vec3 hsv_to_rgb(vec3 hsv) {
    vec3 rgb = hue_to_rgb(hsv.x);
	rgb = mix(vec3(1.0), rgb, hsv.y);
    rgb = rgb * hsv.z;
    return rgb;
}

vec3 rgb_to_hsv(vec3 rgb) {
    float maxComponent = max(rgb.r, max(rgb.g, rgb.b));
    float minComponent = min(rgb.r, min(rgb.g, rgb.b));
    float diff = maxComponent - minComponent;
    float hue = 0.0;
    if(maxComponent == rgb.r) {
        hue = 0.0 + (rgb.g - rgb.b) / diff;
    } else if(maxComponent == rgb.g) {
        hue = 2.0 + (rgb.b - rgb.r) / diff;
    } else if(maxComponent == rgb.b) {
        hue = 4.0 + (rgb.r - rgb.g) / diff;
    }
    hue = fract(hue / 6.0);
    float saturation;
	if (maxComponent > 0.0) {
		saturation = diff / maxComponent;
	}
	else {
		saturation = 0.0;
	}
    float value = maxComponent;
    return vec3(hue, saturation, value);
}

vec3 tune_hsv(int transform_id, vec3 rgb) {
	
	vec3 source_hsv = rgb_to_hsv(rgb);
	vec3 new_hsv = source_hsv + hsv_transforms[transform_id];
	
	return hsv_to_rgb(new_hsv);
}
#endif

#if NUM_COLOR_RAMPS > 0
uniform sampler2D[NUM_COLOR_RAMPS] color_ramp_textures : source_color, repeat_disable;
vec4 get_color_ramp(int color_ramp_id, float fac) {
	//get_color_ramp
	return vec4(0.0);
}
#endif

vec4 sample_texture_ln(sampler2D input_tex, uv_map input_uv) { //for linear filtering textures
	if (input_uv.is_triplanar) {
		vec4 result = vec4(0.0);
		
		if (input_uv.uv1_fac > 0.005) {
        	result += texture(input_tex, input_uv.uv1) * input_uv.uv1_fac;
   		}
    	if (input_uv.uv2_fac > 0.005) {
        	result += texture(input_tex, input_uv.uv2) * input_uv.uv2_fac;
    	}
    	if (input_uv.uv3_fac > 0.005) {
        	result += texture(input_tex, input_uv.uv3) * input_uv.uv3_fac;
    	}
		
		return result;
	}
	else {
		return texture(input_tex, input_uv.uv1);
	}
}

vec4 sample_texture_nn(sampler2D input_tex, uv_map input_uv) { //for nearest neighbor textures
	if (input_uv.is_triplanar) {
		vec4 result = vec4(0.0);
		
		if (input_uv.uv1_fac > 0.005) {
        	result += texture(input_tex, input_uv.uv1) * input_uv.uv1_fac;
   		}
    	if (input_uv.uv2_fac > 0.005) {
        	result += texture(input_tex, input_uv.uv2) * input_uv.uv2_fac;
    	}
    	if (input_uv.uv3_fac > 0.005) {
        	result += texture(input_tex, input_uv.uv3) * input_uv.uv3_fac;
    	}
		
		return result;
	}
	else {
		return texture(input_tex, input_uv.uv1);
	}
}

vec4 sample_texture_nm(sampler2D input_tex, uv_map input_uv) { //for normal maps
	if (input_uv.is_triplanar) {
		vec4 result = vec4(0.0);
		
		if (input_uv.uv1_fac > 0.005) {
        	result += texture(input_tex, input_uv.uv1) * input_uv.uv1_fac;
   		}
    	if (input_uv.uv2_fac > 0.005) {
        	result += texture(input_tex, input_uv.uv2) * input_uv.uv2_fac;
    	}
    	if (input_uv.uv3_fac > 0.005) {
        	result += texture(input_tex, input_uv.uv3) * input_uv.uv3_fac;
    	}
		
		return result;
	}
	else {
		return texture(input_tex, input_uv.uv1);
	}
}

uv_map create_uv_map(vec2 input_uv) {
	uv_map result;
	
	result.uv1 = input_uv;
	result.is_triplanar = false;
	
	return result;
}

uv_map transform_uv(uv_map base_uv, vec2 offset, vec2 scale) {
	base_uv.uv1 += offset;
	base_uv.uv2 += offset;
	base_uv.uv3 += offset;
	
	base_uv.uv1 *= scale;
	base_uv.uv2 *= scale;
	base_uv.uv3 *= scale;
	
	return base_uv;
}

vec3 get_layer_albedo(int layer_index) {
	//get_albedo
	return vec3(0.0);
}

float get_layer_alpha(int layer_index) {
	//get_alpha
	return 1.0;
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

float get_layer_occlusion(int layer_index) {
	//get_occlusion
	return 1.0;
}

void vertex() {
	local_vertex_normal = NORMAL.rgb;
	vec3 normal_scale = vec3(
    	length(MODEL_NORMAL_MATRIX[0].xyz),
    	length(MODEL_NORMAL_MATRIX[1].xyz),
    	length(MODEL_NORMAL_MATRIX[2].xyz)
	);
	hybrid_vertex_normal = local_vertex_normal * normal_scale;
	global_vertex_normal = local_vertex_normal * MODEL_NORMAL_MATRIX;
	
	local_vertex_pos = VERTEX.xyz;
	global_vertex_pos = (MODEL_MATRIX * vec4(local_vertex_pos, 1.0)).xyz;
	vec3 scale = vec3(
    	length(MODEL_MATRIX[0].xyz),
    	length(MODEL_MATRIX[1].xyz),
    	length(MODEL_MATRIX[2].xyz)
	);
	hybrid_vertex_pos = local_vertex_pos * scale;
	
	global_camera_pos = CAMERA_POSITION_WORLD;
	vertex_color = COLOR.rgb;
}

void fragment() {
	
	uv = UV;
	uv2 = UV2;
	
	vec3 albedo_mix;
	vec3 normal_mix;
	float roughness_mix;
	float metallic_mix;
	float occlusion_mix;
	
	int starting_index = 0;
	int process_index = 0;
	
	float[NUM_LAYERS] layer_masks;
	
	//fragment
	
	for (int i = starting_index; i < NUM_LAYERS; i++) {
		if (process_index == 0) { //if this is the first layer we're processing, just force the mask to be 1
			albedo_mix = get_layer_albedo(i);
			normal_mix = get_layer_normal(i);
			roughness_mix = get_layer_roughness(i);
			metallic_mix = get_layer_metallic(i);
			occlusion_mix = get_layer_occlusion(i);
		}
		else if (layer_masks[i] > 0.005) {
			albedo_mix = mix(albedo_mix, get_layer_albedo(i), layer_masks[i] * get_layer_alpha(i));
			
			normal_mix = mix(normal_mix, get_layer_normal(i), layer_masks[i]);
			roughness_mix = mix(roughness_mix, get_layer_roughness(i), layer_masks[i]);
			metallic_mix = mix(metallic_mix, get_layer_metallic(i), layer_masks[i]);
			occlusion_mix = mix(occlusion_mix, get_layer_occlusion(i), layer_masks[i]);
		}
		
		process_index += 1;
	}
	
	ALBEDO = albedo_mix;
	NORMAL_MAP = normal_mix;
	ROUGHNESS = roughness_mix;
	METALLIC = metallic_mix;
	AO = occlusion_mix;
	
}
