shader_type spatial;

render_mode cull_disabled, depth_prepass_alpha;

uniform int albedo_channel = 0;

group_uniforms vertex_displacement;
uniform int vertex_displacement_mode : hint_enum("Disabled", "Normal") = 0;
uniform float vertex_displacement_scale = -1.0;
uniform sampler2D vertex_displacement_map : hint_default_black;

%parameters

varying vec3 local_vertex_normal;
varying vec3 global_vertex_normal;
varying vec3 global_vertex_pos;
varying vec3 local_vertex_pos;
varying vec3 vertex_color;

bool get_layer_enabled(int layer_index) {
	switch (layer_index) {
		%get_layer_enabled_sc
	}
}

vec2 get_layer_uv_offset(int layer, int uv_map_index, vec2 uv) {
	switch (layer) {
		%get_layer_uv_offset_sc
	}
}

vec2 get_layer_uv(int layer, int uv_map_index, vec2 uv) {
	switch (layer) {
		%get_layer_uv_sc
	}
}

int get_layer_map_uv_index(int layer, int map_index) {
	switch (layer) {
		%get_layer_map_uv_index_sc
	}
}

int get_layer_mask_mixing_step(int layer, int mask) {
	switch (layer) {
		%get_layer_mask_mixing_step_sc
	}
}

int get_layer_step_mixing_operation(int layer, int step) {
	switch (layer) {
		%get_layer_step_mixing_operation_sc
	}
}

float get_layer_step_mixing_threshold(int layer, int step) {
	switch (layer) {
		%get_layer_step_mixing_threshold_sc
	}
}

float get_layer_mask_amplification(int layer) {
	switch (layer) {
		%get_layer_mask_amplification_sc
	}
}

float get_layer_mask_post_color_ramp_value(int layer, float factor) {
	switch (layer) {
		%get_layer_mask_post_color_ramp_value_sc
	}
}

int get_layer_post_effect(int layer) {
	switch (layer) {
		%get_layer_post_effect_sc
	}
}

float get_layer_post_effect_parameter(int layer, int parameter_index) {
	switch (layer) {
		%get_layer_post_effect_parameter_sc
	}
}

vec4 get_layer_texture_mask_texture(int layer, int a_or_b, vec2 uv) {
	switch (layer) {
		%get_layer_texture_mask_texture_sc
	}
}

bool get_layer_texture_mask_enabled(int layer, int a_or_b) {
	switch (layer) {
		%get_layer_texture_mask_enabled_sc
	}
}

int get_layer_texture_masks_subtraction_order(int layer) {
	switch (layer) {
		%get_layer_texture_masks_subtraction_order_sc
	}
}

int get_layer_texture_mask_mix_operation(int layer) {
	switch (layer) {
		%get_layer_texture_mask_mix_operation_sc
	}
}

int get_layer_directional_mask_mode(int layer) {
	switch (layer) {
		%get_layer_directional_mask_mode_sc
	}
}

int get_layer_directional_mask_space(int layer) {
	switch (layer) {
		%get_layer_directional_mask_space_sc
	}
}

float get_layer_directional_mask_color_ramp_value(int layer, float factor) {
	switch (layer) {
		%get_layer_directional_mask_color_ramp_value_sc
	}
}

int get_layer_positional_mask_mode(int layer) {
	switch (layer) {
		%get_layer_positional_mask_mode_sc
	}
}

int get_layer_positional_mask_axis(int layer) {
	switch (layer) {
		%get_layer_positional_mask_axis_sc
	}
}

float get_layer_positional_mask_min(int layer) {
	switch (layer) {
		%get_layer_positional_mask_min_sc
	}
}

float get_layer_positional_mask_max(int layer) {
	switch (layer) {
		%get_layer_positional_mask_max_sc
	}
}

float get_layer_positional_mask_color_ramp_value(int layer, float factor) {
	switch (layer) {
		%get_layer_positional_mask_color_ramp_value_sc
	}
}

int get_layer_vertex_color_mask_mode(int layer) {
	switch (layer) {
		%get_layer_vertex_color_mask_mode_sc
	}
}

float get_layer_vertex_color_mask_color_ramp_value(int layer, float factor) {
	switch (layer) {
		%get_layer_vertex_color_mask_color_ramp_value_sc
	}
}

int get_layer_normal_map_slope_mask_mode(int layer) {
	switch (layer) {
		%get_layer_normal_map_slope_mask_mode_sc
	}
}

float get_layer_normal_map_slope_mask_color_ramp_value(int layer, float factor) {
	switch (layer) {
		%get_layer_normal_map_slope_mask_color_ramp_value_sc
	}
}

bool get_layer_uv_mask_enabled(int layer) {
	switch (layer) {
		%get_layer_uv_mask_enabled_sc
	}
}

int get_layer_uv_mask_mixing_operation(int layer) {
	switch (layer) {
		%get_layer_uv_mask_mixing_operation_sc
	}
}

int get_layer_uv_mask_mixing_order(int layer) {
	switch (layer) {
		%get_layer_uv_mask_mixing_order_sc
	}
}

float get_layer_uv_mask_color_ramp_value(int layer, bool axis, float factor) {
	switch (layer) {
		%get_layer_uv_mask_color_ramp_value_sc
	}
}

float get_layer_uv_mask_min(int layer, bool axis) {
	switch (layer) {
		%get_layer_uv_mask_min_sc
	}
}

float get_layer_uv_mask_max(int layer, bool axis) {
	switch (layer) {
		%get_layer_uv_mask_max_sc
	}
}


float get_texture_mask_for_layer(int layer, vec2 mask_a_uv, vec2 mask_b_uv) {
	float texture_mask_mix;

	vec4 texture_mask_A_texture = get_layer_texture_mask_texture(layer, 0, mask_a_uv);
	vec4 texture_mask_B_texture = get_layer_texture_mask_texture(layer, 1, mask_b_uv);

	int texture_masks_subtraction_order = get_layer_texture_masks_subtraction_order(layer);

	bool texture_mask_A_enabled = get_layer_texture_mask_enabled(layer, 0);
	bool texture_mask_B_enabled = get_layer_texture_mask_enabled(layer, 1);

	switch (get_layer_texture_mask_mix_operation(layer)) {
		case 0:
			texture_mask_mix = (texture_mask_A_texture.r * texture_mask_A_texture.a * float(texture_mask_A_enabled)) + (texture_mask_B_texture.r * texture_mask_B_texture.a * float(texture_mask_B_enabled));
			break;
		case 1:
			switch (texture_masks_subtraction_order) {
				case 0:
					texture_mask_mix = (texture_mask_A_texture.r * texture_mask_A_texture.a * float(texture_mask_A_enabled)) - (texture_mask_B_texture.r * texture_mask_B_texture.a * float(texture_mask_B_enabled));
					break;
				case 1:
					texture_mask_mix = (texture_mask_B_texture.r * texture_mask_B_texture.a * float(texture_mask_B_enabled)) - (texture_mask_A_texture.r * texture_mask_A_texture.a * float(texture_mask_A_enabled));
					break;
			}
			break;
		case 2:
			texture_mask_mix = texture_mask_A_texture.r * texture_mask_B_texture.r;
			break;
	}

	return texture_mask_mix;
}

float get_directional_mask_for_layer(int layer, vec3 local_surface_normal, vec3 global_surface_normal) {
		vec3 surface_normal = local_surface_normal * float(get_layer_directional_mask_space(layer) == 1) + global_surface_normal * float(get_layer_directional_mask_space(layer) == 0);
		switch (get_layer_directional_mask_mode(layer)) {
			case 0:
				return 0.0;
			case 1:
				return (abs(surface_normal.r) * get_layer_directional_mask_color_ramp_value(layer, abs(surface_normal.r)));
			case 2:
				return (clamp(surface_normal.r, 0.0, 1.0) * get_layer_directional_mask_color_ramp_value(layer, clamp(surface_normal.r, 0.0, 1.0)));
			case 3:
				return (abs(clamp(surface_normal.r, -1.0, 0.0)) * get_layer_directional_mask_color_ramp_value(layer, abs(clamp(surface_normal.r, -1.0, 0.0))));
			case 4:
				return (abs(surface_normal.g) * get_layer_directional_mask_color_ramp_value(layer, abs(surface_normal.g)));
			case 5:
				return (clamp(surface_normal.g, 0.0, 1.0) * get_layer_directional_mask_color_ramp_value(layer, clamp(surface_normal.g, 0.0, 1.0)));
			case 6:
				return (abs(clamp(surface_normal.g, -1.0, 0.0)) * get_layer_directional_mask_color_ramp_value(layer, abs(clamp(surface_normal.g, -1.0, 0.0))));
			case 7:
				return (abs(surface_normal.b) * get_layer_directional_mask_color_ramp_value(layer, abs(surface_normal.b)));
			case 8:
				return (clamp(surface_normal.b, 0.0, 1.0) * get_layer_directional_mask_color_ramp_value(layer, clamp(surface_normal.b, 0.0, 1.0)));
			case 9:
				return (abs(clamp(surface_normal.b, -1.0, 0.0)) * get_layer_directional_mask_color_ramp_value(layer, abs(clamp(surface_normal.b, -1.0, 0.0))));
			}
}

float get_positional_mask_for_layer(int layer, vec3 local_v_position, vec3 global_v_position) {
	float positional_mask_value;
	float positional_mask_max = get_layer_positional_mask_max(layer);
	float positional_mask_min = get_layer_positional_mask_min(layer);

	vec3 v_position = (float(get_layer_positional_mask_mode(layer) == 1) * local_v_position) + (float(get_layer_positional_mask_mode(layer) == 2) * global_v_position);

	switch (get_layer_positional_mask_axis(layer)) {
			case 0:
				positional_mask_value = clamp(1.0/(positional_mask_max - positional_mask_min) * v_position.x + (1.0 - 1.0/(positional_mask_max - positional_mask_min) * positional_mask_max), 0.002, 0.998);
				return get_layer_positional_mask_color_ramp_value(layer, positional_mask_value) * float(get_layer_positional_mask_mode(layer) != 0);
			case 1:
				positional_mask_value = clamp(1.0/(positional_mask_max - positional_mask_min) * v_position.y + (1.0 - 1.0/(positional_mask_max - positional_mask_min) * positional_mask_max), 0.002, 0.998);
				return get_layer_positional_mask_color_ramp_value(layer, positional_mask_value) * float(get_layer_positional_mask_mode(layer) != 0);
			case 2:
				positional_mask_value = clamp(1.0/(positional_mask_max - positional_mask_min) * v_position.z + (1.0 - 1.0/(positional_mask_max - positional_mask_min) * positional_mask_max), 0.002, 0.998);
				return get_layer_positional_mask_color_ramp_value(layer, positional_mask_value) * float(get_layer_positional_mask_mode(layer) != 0);
		}
}

float get_vertex_color_mask_for_layer(int layer) {
	switch (get_layer_vertex_color_mask_mode(layer)) {
		case 0:
			return 0.0;
		case 1:
			return get_layer_vertex_color_mask_color_ramp_value(layer, vertex_color.r);
		case 2:
			return get_layer_vertex_color_mask_color_ramp_value(layer, vertex_color.g);
		case 3:
			return get_layer_vertex_color_mask_color_ramp_value(layer, vertex_color.b);
		}
}

float get_normal_map_slope_mask_for_layer(int layer, vec2 uv) {
	switch (layer) {
		%get_normal_map_slope_mask_for_layer_sc
	}
}

float get_uv_mask_for_layer(int layer, vec2 uv) {
	float x_max = get_layer_uv_mask_max(layer, false);
	float x_min = get_layer_uv_mask_min(layer, false);
	float x_factor = clamp(1.0/(x_max - x_min) * uv.x + (1.0 - 1.0/(x_max - x_min) * x_max), 0.002, 0.998);
	float x_value = get_layer_uv_mask_color_ramp_value(layer, false, x_factor);

	float y_max = get_layer_uv_mask_max(layer, true);
	float y_min = get_layer_uv_mask_min(layer, true);
	float y_factor = clamp(1.0/(y_max - y_min) * uv.y + (1.0 - 1.0/(y_max - y_min) * y_max), 0.002, 0.998);
	float y_value = get_layer_uv_mask_color_ramp_value(layer, true, y_factor);

	float result;

	switch (get_layer_uv_mask_mixing_operation(layer)) {
		case 0:
			result = y_value + x_value;
		case 1:
			switch (get_layer_uv_mask_mixing_order(layer)) {
				case 0:
					result = x_value - y_value;
				case 1:
					result = y_value - x_value;
			};
		case 2:
			result = y_value * x_value;
	};

	return result * float(get_layer_uv_mask_enabled(layer));
}

float get_layer_mask_step_mix(int layer, int step, vec2 uv1, vec2 uv2, vec3 local_surface_normal, vec3 global_surface_normal, vec3 local_vertex_position, vec3 global_vertex_position) {
	vec2 mask_a_uv = (uv1 * float(get_layer_map_uv_index(layer, 5) == 0) + uv2 * float(get_layer_map_uv_index(1, 5) == 1)) * float(layer == 1) + (uv1 * float(get_layer_map_uv_index(layer, 5) == 0) + uv2 * float(get_layer_map_uv_index(layer, 5) == 1)) * float(layer == 2) + (uv1 * float(get_layer_map_uv_index(layer, 5) == 0) + uv2 * float(get_layer_map_uv_index(layer, 5) == 1)) * float(layer == 3);
	vec2 mask_b_uv = (uv1 * float(get_layer_map_uv_index(layer, 6) == 0) + uv2 * float(get_layer_map_uv_index(1, 6) == 1)) * float(layer == 1) + (uv1 * float(get_layer_map_uv_index(layer, 6) == 0) + uv2 * float(get_layer_map_uv_index(layer, 6) == 1)) * float(layer == 2) + (uv1 * float(get_layer_map_uv_index(layer, 6) == 0) + uv2 * float(get_layer_map_uv_index(layer, 6) == 1)) * float(layer == 3);

	vec2 uv_mask_uv = (uv1 * float(get_layer_map_uv_index(1, 7) == 0) + uv2 * float(get_layer_map_uv_index(1, 7) == 1)) * float(layer == 1) + (uv1 * float(get_layer_map_uv_index(2, 7) == 0) + uv2 * float(get_layer_map_uv_index(2, 7) == 1)) * float(layer == 2) + (uv1 * float(get_layer_map_uv_index(3, 7) == 0) + uv2 * float(get_layer_map_uv_index(3, 7) == 1)) * float(layer == 3);

	vec2 normal_map_uv = uv1 * float(get_layer_map_uv_index(layer, 0) == 0) + uv2 * float(get_layer_map_uv_index(layer, 0) == 1);

	return clamp((get_texture_mask_for_layer(layer, mask_a_uv, mask_b_uv) * float(get_layer_mask_mixing_step(layer, 1) == step) + get_directional_mask_for_layer(layer, local_surface_normal, global_surface_normal) * float(get_layer_mask_mixing_step(layer, 2) == step) + get_positional_mask_for_layer(layer, local_vertex_position, global_vertex_position) * float(get_layer_mask_mixing_step(layer, 3) == step) + get_vertex_color_mask_for_layer(layer) * float(get_layer_mask_mixing_step(layer, 4) == step) + get_normal_map_slope_mask_for_layer(layer, normal_map_uv) * float(get_layer_mask_mixing_step(layer, 5) == step) + get_uv_mask_for_layer(layer, uv_mask_uv) * float(get_layer_mask_mixing_step(layer, 6) == step)), 0.0, 1.0);
}

float get_resulting_mask_for_layer(int layer, vec2 uv1, vec2 uv2, vec3 local_surface_normal, vec3 global_surface_normal, vec3 local_vertex_position, vec3 global_vertex_position) {
	float step_1_mix = get_layer_mask_step_mix(layer, 1, uv1, uv2, local_surface_normal, global_surface_normal, local_vertex_position, global_vertex_position);

	float step_2_mix = get_layer_mask_step_mix(layer, 2, uv1, uv2, local_surface_normal, global_surface_normal, local_vertex_position, global_vertex_position);
	switch (get_layer_step_mixing_operation(layer, 2)) {
		case 0:
			step_2_mix = clamp(step_1_mix + (step_2_mix * float(step_1_mix >= get_layer_step_mixing_threshold(layer, 2))), 0.0, 1.0);
			break;
		case 1:
			step_2_mix = clamp(step_1_mix - (step_2_mix * float(step_1_mix >= get_layer_step_mixing_threshold(layer, 2))), 0.0, 1.0);
			break;
		case 2:
			if (step_1_mix >= get_layer_step_mixing_threshold(layer, 2)) {
				step_2_mix = clamp(step_1_mix * step_2_mix, 0.0, 1.0);
			}
			else {
				step_2_mix = step_1_mix;
				}
			break;
	}

	float step_3_mix = get_layer_mask_step_mix(layer, 3, uv1, uv2, local_surface_normal, global_surface_normal, local_vertex_position, global_vertex_position);
	switch (get_layer_step_mixing_operation(layer, 3)) {
		case 0:
			step_3_mix = clamp(step_2_mix + (step_3_mix * float(step_2_mix >= get_layer_step_mixing_threshold(layer, 3))), 0.0, 1.0);
			break;
		case 1:
			step_3_mix = clamp(step_2_mix - (step_3_mix * float(step_2_mix >= get_layer_step_mixing_threshold(layer, 3))), 0.0, 1.0);
			break;
		case 2:
			if (step_2_mix >= get_layer_step_mixing_threshold(layer, 3)) {
				step_3_mix = clamp(step_2_mix * step_3_mix, 0.0, 1.0);
			}
			else {
				step_3_mix = step_2_mix;
				}
			break;
	}

	float step_4_mix = get_layer_mask_step_mix(layer, 4, uv1, uv2, local_surface_normal, global_surface_normal, local_vertex_position, global_vertex_position);
	switch (get_layer_step_mixing_operation(layer, 4)) {
		case 0:
			step_4_mix = clamp(step_3_mix + (step_4_mix * float(step_3_mix >= get_layer_step_mixing_threshold(layer, 4))), 0.0, 1.0);
			break;
		case 1:
			step_4_mix = clamp(step_3_mix - (step_4_mix * float(step_3_mix >= get_layer_step_mixing_threshold(layer, 4))), 0.0, 1.0);
			break;
		case 2:
			if (step_3_mix >= get_layer_step_mixing_threshold(layer, 4)) {
				step_4_mix = clamp(step_3_mix * step_4_mix, 0.0, 1.0);
			}
			else {
				step_4_mix = step_3_mix;
				}
			break;
	}

	float step_5_mix = get_layer_mask_step_mix(layer, 5, uv1, uv2, local_surface_normal, global_surface_normal, local_vertex_position, global_vertex_position);
	switch (get_layer_step_mixing_operation(layer, 5)) {
		case 0:
			step_5_mix = clamp(step_4_mix + (step_5_mix * float(step_4_mix >= get_layer_step_mixing_threshold(layer, 5))), 0.0, 1.0);
			break;
		case 1:
			step_5_mix = clamp(step_4_mix - (step_5_mix * float(step_4_mix >= get_layer_step_mixing_threshold(layer, 5))), 0.0, 1.0);
			break;
		case 2:
			if (step_4_mix >= get_layer_step_mixing_threshold(layer, 5)) {
				step_5_mix = clamp(step_4_mix * step_5_mix, 0.0, 1.0);
			}
			else {
				step_5_mix = step_4_mix;
				}
			break;
	}

	float step_6_mix = get_layer_mask_step_mix(layer, 6, uv1, uv2, local_surface_normal, global_surface_normal, local_vertex_position, global_vertex_position);
	switch (get_layer_step_mixing_operation(layer, 6)) {
		case 0:
			step_6_mix = clamp(step_4_mix + (step_6_mix * float(step_5_mix >= get_layer_step_mixing_threshold(layer, 6))), 0.0, 1.0);
			break;
		case 1:
			step_6_mix = clamp(step_4_mix - (step_6_mix * float(step_5_mix >= get_layer_step_mixing_threshold(layer, 6))), 0.0, 1.0);
			break;
		case 2:
			if (step_5_mix >= get_layer_step_mixing_threshold(layer, 6)) {
				step_6_mix = clamp(step_5_mix * step_6_mix, 0.0, 1.0);
			}
			else {
				step_6_mix = step_5_mix;
				}
			break;
	}

	switch (get_layer_post_effect(layer)) {
		case 1:
			step_6_mix = step_6_mix + 0.1;
		case 2:
			step_6_mix = 0.0;
	};

	return get_layer_mask_post_color_ramp_value(layer, clamp(step_5_mix, 0.0, 1.0) * get_layer_mask_amplification(layer) + 0.002);
}

void vertex() {
	switch (vertex_displacement_mode) {
		case 1:
			VERTEX.xyz += NORMAL.xyz * vertex_displacement_scale * texture(vertex_displacement_map, UV).r;
			break;
	}
	local_vertex_normal = NORMAL.rgb;
	global_vertex_normal = local_vertex_normal * MODEL_NORMAL_MATRIX;
	local_vertex_pos = VERTEX.xyz;
	global_vertex_pos = (vec4(local_vertex_normal, 1.0) * MODEL_MATRIX).xyz;
}

void fragment() {
	vertex_color = COLOR.rgb;

	vec3 albedo_mix = vec3(0.0, 0.0, 0.0);
	float occlusion_mix = 0.0;
	float roughness_mix = 0.5;
	float metallic_mix = 0.0;
	vec3 normal_mix = vec3(0.5, 1.0, 0.5);

	%layer_fragment_snippets

	switch (albedo_channel) {
		case 0:
			ALBEDO = albedo_mix.rgb;
			break;
		case 1:
			ALBEDO = vec3(roughness_mix);
			break;
		case 2:
			ALBEDO = vec3(metallic_mix);
			break;
		case 3:
			ALBEDO = normal_mix;
			break;
	};
	ROUGHNESS = roughness_mix;
	METALLIC = metallic_mix;

	NORMAL_MAP = normal_mix;
}