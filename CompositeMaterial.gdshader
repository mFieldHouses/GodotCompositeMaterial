shader_type spatial;

//Todo: normal map generator, local space variation, triplanar mapping, vertex displacement?, masked addition, masked subtraction

//render_mode unshaded;

group_uniforms layer_3;
/**
 * Whether this layer will display at all.
 */
uniform bool layer_3_enabled = true;
/**
 * X and Y components by which the size of the UV map will be multiplied.
 */
uniform vec2 layer_3_uv_scale = vec2(1.0);
uniform vec2 layer_3_uv_offset = vec2(0.0);
uniform sampler2D layer_3_albedo : source_color, hint_default_transparent;

uniform sampler2D layer_3_normal : hint_normal;
/**
 * Whether this layer should use the same normal map as the underlying layer.
 */
uniform bool layer_3_propagate_normals = false;

group_uniforms layer_3.ORM;
uniform int layer_3_orm_mode : hint_enum("Single map", "Seperate maps") = 0;
uniform sampler2D layer_3_orm_map : hint_default_transparent;
uniform sampler2D layer_3_occlusion_map : hint_default_transparent;
uniform sampler2D layer_3_roughness_map : hint_default_transparent;
uniform sampler2D layer_3_metallic_map : hint_default_transparent;
/**
 * Whether this layer should use the same ORM texture as the underlying layer.
 */
group_uniforms layer_3.masking;
/**
 * Whether this layer should display only its masks in black and white.
 */
uniform bool layer_3_consolidate_masks = false;
/**
 * Number by which the intensity of the resulting mask (A, B and Directional) will be multiplied.
 */
uniform float layer_3_mask_amplification : hint_range(0.0, 10.0) = 1.0;

uniform int layer_3_step_2_mixing_operation : hint_enum("Add", "Subtract", "Multiply", "Masked Add") = 0;
uniform int layer_3_step_3_mixing_operation : hint_enum("Add", "Subtract", "Multiply", "Masked Add") = 0;
uniform int layer_3_step_4_mixing_operation : hint_enum("Add", "Subtract", "Multiply", "Masked Add") = 0;
uniform sampler2D layer_3_post_color_ramp : hint_default_white;

group_uniforms layer_3.texture_masks;
uniform bool layer_3_texture_mask_A_enabled = true;
uniform sampler2D layer_3_texture_mask_A : hint_default_transparent;
uniform bool layer_3_texture_mask_B_enabled = false;
uniform sampler2D layer_3_texture_mask_B : hint_default_transparent;

/**
 * What operation will be executed to mix masks A and B together. Depending on the mixing operation, the "Enabled" property per mask may be ignored.
 */
uniform int layer_3_texture_masks_mix_operation: hint_enum("Add", "Subtract", "Multiply") = 0;
/**
 * In what order masks A and B will be substracted from one another when the mix mode is set to "subtract".
 */
uniform int layer_3_texture_masks_subtraction_order: hint_enum("A - B", "B - A") = 0;
uniform int layer_3_texture_masks_mixing_step: hint_enum("Step 1:1", "Step 2:2", "Step 3:3", "Step 4:4") = 1;

group_uniforms layer_3.directional_mask;
/**
 * Whether to generate a mask which is multiplied with the direction of the normals of the mesh, dependant on the direction chosen.
 */
uniform int layer_3_directional_mask_mode : hint_enum("Disabled", "X", "X+", "X-", "Y", "Y+", "Y-", "Z", "Z+", "Z-");
uniform int layer_3_directional_mask_space : hint_enum("Global", "Local") = 0;
uniform sampler2D layer_3_directional_mask_color_ramp : hint_default_transparent;
uniform int layer_3_directional_mask_mixing_step: hint_enum("Step 1:1", "Step 2:2", "Step 3:3", "Step 4:4") = 2;

group_uniforms layer_3.positional_mask;
uniform int layer_3_positional_mask_mode : hint_enum("Disabled", "Local", "Global") = 0;
uniform sampler2D layer_3_positional_mask_color_ramp : hint_default_transparent;
uniform int layer_3_positional_mask_axis : hint_enum("X", "Y", "Z") = 1;
/**
 * Position on the axis chosen starting at which the mask is 1. Doesn't apply to the Local positional mask mode.
 */
uniform float layer_3_positional_mask_max = 1.0;
/**
 * Position on the axis chosen starting at which the mask is 0. Doesn't apply to the Local positional mask mode.
 */
uniform float layer_3_positional_mask_min = -1.0;
/**
 * What operation will be executed to mix masks ABD (already mixed) and the Positional Mask together.
 */
uniform int layer_3_positional_mask_mixing_step: hint_enum("Step 1:1", "Step 2:2", "Step 3:3", "Step 4:4") = 3;


group_uniforms layer_3.vertex_color_mask;
/**
 * Whether to use the objects vertex color properties as a mask. Useful for edgewear or adding deliberate spots of material to terrain.
 */
uniform int layer_3_vertex_color_mask_mode : hint_enum("Disabled", "Red", "Green", "Blue") = 0;
uniform sampler2D layer_3_vertex_color_mask_color_ramp : hint_default_white;
uniform int layer_3_vertex_color_mask_mixing_step: hint_enum("Step 1:1", "Step 2:2", "Step 3:3", "Step 4:4") = 4;

group_uniforms layer_3.normal_map_generator;
/**
 * Whether to generate a normal map based on the generated mask for this layer. Will disable the normal map texture.
 */
uniform int layer_3_generate_normals : hint_enum("Disabled", "Mask", "Albedo", "Mask + Albedo");
uniform float layer_3_mask_normal_scale : hint_range(-1.0, 1.0) = 0.0;
uniform float layer_3_mask_normal_radius : hint_range(1.0, 100.0) = 5.0;




//==========================================================================


//==========================================================================




group_uniforms layer_2;
/**
 * Whether this layer will display at all.
 */
uniform bool layer_2_enabled = true;
/**
 * X and Y components by which the size of the UV map will be multiplied.
 */
uniform vec2 layer_2_uv_scale = vec2(1.0);
uniform vec2 layer_2_uv_offset = vec2(0.0);
uniform sampler2D layer_2_albedo : source_color, hint_default_transparent;

uniform sampler2D layer_2_normal : hint_normal;
/**
 * Whether this layer should use the same normal map as the underlying layer.
 */
uniform bool layer_2_propagate_normals = false;

group_uniforms layer_2.ORM;
uniform int layer_2_orm_mode : hint_enum("Single map", "Seperate maps") = 0;
uniform sampler2D layer_2_orm_map : hint_default_transparent;
uniform sampler2D layer_2_occlusion_map : hint_default_transparent;
uniform sampler2D layer_2_roughness_map : hint_default_transparent;
uniform sampler2D layer_2_metallic_map : hint_default_transparent;
/**
 * Whether this layer should use the same ORM texture as the underlying layer.
 */
group_uniforms layer_2.masking;
/**
 * Whether this layer should display only its masks in black and white.
 */
uniform bool layer_2_consolidate_masks = false;
/**
 * Number by which the intensity of the resulting mask (A, B and Directional) will be multiplied.
 */
uniform float layer_2_mask_amplification : hint_range(0.0, 10.0) = 1.0;

uniform int layer_2_step_2_mixing_operation : hint_enum("Add", "Subtract", "Multiply", "Masked Add") = 0;
uniform int layer_2_step_3_mixing_operation : hint_enum("Add", "Subtract", "Multiply", "Masked Add") = 0;
uniform int layer_2_step_4_mixing_operation : hint_enum("Add", "Subtract", "Multiply", "Masked Add") = 0;
uniform sampler2D layer_2_post_color_ramp : hint_default_white;

group_uniforms layer_2.texture_masks;
uniform bool layer_2_texture_mask_A_enabled = true;
uniform sampler2D layer_2_texture_mask_A : hint_default_transparent;
uniform bool layer_2_texture_mask_B_enabled = false;
uniform sampler2D layer_2_texture_mask_B : hint_default_transparent;

/**
 * What operation will be executed to mix masks A and B together. Depending on the mixing operation, the "Enabled" property per mask may be ignored.
 */
uniform int layer_2_texture_masks_mix_operation: hint_enum("Add", "Subtract", "Multiply") = 0;
/**
 * In what order masks A and B will be substracted from one another when the mix mode is set to "subtract".
 */
uniform int layer_2_texture_masks_subtraction_order: hint_enum("A - B", "B - A") = 0;
uniform int layer_2_texture_masks_mixing_step: hint_enum("Step 1:1", "Step 2:2", "Step 3:3", "Step 4:4") = 1;

group_uniforms layer_2.directional_mask;
/**
 * Whether to generate a mask which is multiplied with the direction of the normals of the mesh, dependant on the direction chosen.
 */
uniform int layer_2_directional_mask_mode : hint_enum("Disabled", "X", "X+", "X-", "Y", "Y+", "Y-", "Z", "Z+", "Z-");
uniform int layer_2_directional_mask_space : hint_enum("Global", "Local") = 0;
uniform sampler2D layer_2_directional_mask_color_ramp : hint_default_transparent;
uniform int layer_2_directional_mask_mixing_step: hint_enum("Step 1:1", "Step 2:2", "Step 3:3", "Step 4:4") = 2;

group_uniforms layer_2.positional_mask;
uniform int layer_2_positional_mask_mode : hint_enum("Disabled", "Local", "Global") = 0;
uniform sampler2D layer_2_positional_mask_color_ramp : hint_default_transparent;
uniform int layer_2_positional_mask_axis : hint_enum("X", "Y", "Z") = 1;
/**
 * Position on the axis chosen starting at which the mask is 1. Doesn't apply to the Local positional mask mode.
 */
uniform float layer_2_positional_mask_max = 1.0;
/**
 * Position on the axis chosen starting at which the mask is 0. Doesn't apply to the Local positional mask mode.
 */
uniform float layer_2_positional_mask_min = -1.0;
/**
 * What operation will be executed to mix masks ABD (already mixed) and the Positional Mask together.
 */
uniform int layer_2_positional_mask_mixing_step: hint_enum("Step 1:1", "Step 2:2", "Step 3:3", "Step 4:4") = 3;


group_uniforms layer_2.vertex_color_mask;
/**
 * Whether to use the objects vertex color properties as a mask. Useful for edgewear or adding deliberate spots of material to terrain.
 */
uniform int layer_2_vertex_color_mask_mode : hint_enum("Disabled", "Red", "Green", "Blue") = 0;
uniform sampler2D layer_2_vertex_color_mask_color_ramp : hint_default_white;
uniform int layer_2_vertex_color_mask_mixing_step: hint_enum("Step 1:1", "Step 2:2", "Step 3:3", "Step 4:4") = 4;

group_uniforms layer_2.normal_map_generator;
/**
 * Whether to generate a normal map based on the generated mask for this layer. Will disable the normal map texture.
 */
uniform int layer_2_generate_normals : hint_enum("Disabled", "Mask", "Albedo", "Mask + Albedo");
uniform float layer_2_mask_normal_scale : hint_range(-1.0, 1.0) = 0.0;
uniform float layer_2_mask_normal_radius : hint_range(1.0, 100.0) = 5.0;




//==========================================================================


//==========================================================================




group_uniforms layer_1;
/**
 * Whether this layer will display at all.
 */
uniform bool layer_1_enabled = true;
/**
 * X and Y components by which the size of the UV map will be multiplied.
 */
uniform vec2 layer_1_uv_scale = vec2(1.0);
uniform vec2 layer_1_uv_offset = vec2(0.0);
uniform sampler2D layer_1_albedo : source_color, hint_default_transparent;

uniform sampler2D layer_1_normal : hint_normal;
/**
 * Whether this layer should use the same normal map as the underlying layer.
 */
uniform bool layer_1_propagate_normals = false;

group_uniforms layer_1.ORM;
uniform int layer_1_orm_mode : hint_enum("Single map", "Seperate maps") = 0;
uniform sampler2D layer_1_orm_map : hint_default_transparent;
uniform sampler2D layer_1_occlusion_map : hint_default_transparent;
uniform sampler2D layer_1_roughness_map : hint_default_transparent;
uniform sampler2D layer_1_metallic_map : hint_default_transparent;
/**
 * Whether this layer should use the same ORM texture as the underlying layer.
 */
group_uniforms layer_1.masking;
/**
 * Whether this layer should display only its masks in black and white.
 */
uniform bool layer_1_consolidate_masks = false;
/**
 * Number by which the intensity of the resulting mask (A, B and Directional) will be multiplied.
 */
uniform float layer_1_mask_amplification : hint_range(0.0, 10.0) = 1.0;

uniform int layer_1_step_2_mixing_operation : hint_enum("Add", "Subtract", "Multiply", "Masked Add") = 0;
uniform int layer_1_step_3_mixing_operation : hint_enum("Add", "Subtract", "Multiply", "Masked Add") = 0;
uniform int layer_1_step_4_mixing_operation : hint_enum("Add", "Subtract", "Multiply", "Masked Add") = 0;
uniform sampler2D layer_1_post_color_ramp : hint_default_white;

group_uniforms layer_1.texture_masks;
uniform bool layer_1_texture_mask_A_enabled = true;
uniform sampler2D layer_1_texture_mask_A : hint_default_transparent;
uniform bool layer_1_texture_mask_B_enabled = false;
uniform sampler2D layer_1_texture_mask_B : hint_default_transparent;

/**
 * What operation will be executed to mix masks A and B together. Depending on the mixing operation, the "Enabled" property per mask may be ignored.
 */
uniform int layer_1_texture_masks_mix_operation: hint_enum("Add", "Subtract", "Multiply") = 0;
/**
 * In what order masks A and B will be substracted from one another when the mix mode is set to "subtract".
 */
uniform int layer_1_texture_masks_subtraction_order: hint_enum("A - B", "B - A") = 0;
uniform int layer_1_texture_masks_mixing_step: hint_enum("Step 1:1", "Step 2:2", "Step 3:3", "Step 4:4") = 1;

group_uniforms layer_1.directional_mask;
/**
 * Whether to generate a mask which is multiplied with the direction of the normals of the mesh, dependant on the direction chosen.
 */
uniform int layer_1_directional_mask_mode : hint_enum("Disabled", "X", "X+", "X-", "Y", "Y+", "Y-", "Z", "Z+", "Z-");
uniform int layer_1_directional_mask_space : hint_enum("Global", "Local") = 0;
uniform sampler2D layer_1_directional_mask_color_ramp : hint_default_transparent;
uniform int layer_1_directional_mask_mixing_step: hint_enum("Step 1:1", "Step 2:2", "Step 3:3", "Step 4:4") = 2;

group_uniforms layer_1.positional_mask;
uniform int layer_1_positional_mask_mode : hint_enum("Disabled", "Local", "Global") = 0;
uniform sampler2D layer_1_positional_mask_color_ramp : hint_default_transparent;
uniform int layer_1_positional_mask_axis : hint_enum("X", "Y", "Z") = 1;
/**
 * Position on the axis chosen starting at which the mask is 1. Doesn't apply to the Local positional mask mode.
 */
uniform float layer_1_positional_mask_max = 1.0;
/**
 * Position on the axis chosen starting at which the mask is 0. Doesn't apply to the Local positional mask mode.
 */
uniform float layer_1_positional_mask_min = -1.0;
/**
 * What operation will be executed to mix masks ABD (already mixed) and the Positional Mask together.
 */
uniform int layer_1_positional_mask_mixing_step: hint_enum("Step 1:1", "Step 2:2", "Step 3:3", "Step 4:4") = 3;


group_uniforms layer_1.vertex_color_mask;
/**
 * Whether to use the objects vertex color properties as a mask. Useful for edgewear or adding deliberate spots of material to terrain.
 */
uniform int layer_1_vertex_color_mask_mode : hint_enum("Disabled", "Red", "Green", "Blue") = 0;
uniform sampler2D layer_1_vertex_color_mask_color_ramp : hint_default_white;
uniform int layer_1_vertex_color_mask_mixing_step: hint_enum("Step 1:1", "Step 2:2", "Step 3:3", "Step 4:4") = 4;

group_uniforms layer_1.normal_map_generator;
/**
 * Whether to generate a normal map based on the generated mask for this layer. Will disable the normal map texture.
 */
uniform int layer_1_generate_normals : hint_enum("Disabled", "Mask", "Albedo", "Mask + Albedo");
uniform float layer_1_mask_normal_scale : hint_range(-1.0, 1.0) = 0.0;
uniform float layer_1_mask_normal_radius : hint_range(1.0, 100.0) = 5.0;




//==========================================================================


//==========================================================================




group_uniforms layer_base;
uniform bool layer_base_enabled = true;
uniform vec2 layer_base_uv_scale = vec2(1.0, 1.0);
uniform vec2 layer_base_uv_offset = vec2(0.0, 0.0);
uniform sampler2D layer_base_albedo : source_color, hint_default_black;
uniform sampler2D layer_base_normal : hint_normal;
uniform sampler2D layer_base_occlusion_map : hint_default_black;
uniform sampler2D layer_base_roughness_map : hint_default_black;
uniform sampler2D layer_base_metallic_map : hint_default_black;

varying vec3 local_vertex_normal;
varying vec3 global_vertex_normal;
varying vec3 global_vertex_pos;
varying vec3 local_vertex_pos;
varying vec3 vertex_color;


int get_layer_mask_mixing_step(int layer, int mask) {
	return (layer_1_texture_masks_mixing_step * int(mask == 1) + layer_1_directional_mask_mixing_step * int(mask == 2) + layer_1_positional_mask_mixing_step * int(mask == 3) + layer_1_vertex_color_mask_mixing_step * int(mask == 4)) * int(layer == 1) + (layer_2_texture_masks_mixing_step * int(mask == 1) + layer_2_directional_mask_mixing_step * int(mask == 2) + layer_2_positional_mask_mixing_step * int(mask == 3) + layer_2_vertex_color_mask_mixing_step * int(mask == 4)) * int(layer == 2) + (layer_3_texture_masks_mixing_step * int(mask == 1) + layer_3_directional_mask_mixing_step * int(mask == 2) + layer_3_positional_mask_mixing_step * int(mask == 3) + layer_3_vertex_color_mask_mixing_step * int(mask == 4)) * int(layer == 3);
}

int get_layer_step_mixing_operation(int layer, int step) {
	return (layer_1_step_2_mixing_operation * int(step == 2) + layer_1_step_3_mixing_operation * int(step == 3) + layer_1_step_4_mixing_operation * int(step == 4)) * int(layer == 1) + (layer_2_step_2_mixing_operation * int(step == 2) + layer_2_step_3_mixing_operation * int(step == 3) + layer_2_step_4_mixing_operation * int(step == 4)) * int(layer == 2) + (layer_3_step_2_mixing_operation * int(step == 2) + layer_3_step_3_mixing_operation * int(step == 3) + layer_3_step_4_mixing_operation * int(step == 4)) * int(layer == 3);
}

float get_layer_mask_amplification(int layer) {
	switch (layer) {
		case 1:
			return layer_1_mask_amplification;
		case 2:
			return layer_2_mask_amplification;
		case 3:
			return layer_3_mask_amplification;
	}
}

float get_layer_mask_post_color_ramp_value(int layer, float factor) {
	switch (layer) {
		case 1:
			vec2 color_ramp_factor = texture(layer_1_post_color_ramp, vec2((factor * 0.95) + 0.025)).ra;
			return mix(factor, color_ramp_factor.x, color_ramp_factor.y);
		case 2:
			vec2 color_ramp_factor = texture(layer_2_post_color_ramp, vec2((factor * 0.95) + 0.025)).ra;
			return mix(factor, color_ramp_factor.x, color_ramp_factor.y);
		case 3:
			vec2 color_ramp_factor = texture(layer_3_post_color_ramp, vec2((factor * 0.95) + 0.025)).ra;
			return mix(factor, color_ramp_factor.x, color_ramp_factor.y);
	}
}

vec4 get_layer_texture_mask_texture(int layer, int a_or_b, vec2 uv) {
	switch (layer) {
		case 1:
			return (texture(layer_1_texture_mask_A, uv) * (1.0 - float(a_or_b))) + (texture(layer_1_texture_mask_B, uv) * float(a_or_b));
		case 2:
			return (texture(layer_2_texture_mask_A, uv) * (1.0 - float(a_or_b))) + (texture(layer_2_texture_mask_B, uv) * float(a_or_b));
		case 3:
			return (texture(layer_3_texture_mask_A, uv) * (1.0 - float(a_or_b))) + (texture(layer_3_texture_mask_B, uv) * float(a_or_b));
	}
}

bool get_layer_texture_mask_enabled(int layer, int a_or_b) {
	switch (layer) {
		case 1:
			return layer_1_texture_mask_A_enabled && (bool(a_or_b) == false) || layer_1_texture_mask_B_enabled && (bool(a_or_b) == true);
		case 2:
			return layer_2_texture_mask_A_enabled && (bool(a_or_b) == false) || layer_2_texture_mask_B_enabled && (bool(a_or_b) == true);
		case 3:
			return layer_3_texture_mask_A_enabled && (bool(a_or_b) == false) || layer_3_texture_mask_B_enabled && (bool(a_or_b) == true);
	}
}

int get_layer_texture_masks_subtraction_order(int layer) {
	switch (layer) {
		case 1:
			return layer_1_texture_masks_subtraction_order;
		case 2:
			return layer_2_texture_masks_subtraction_order;
		case 3:
			return layer_3_texture_masks_subtraction_order;
	}
}

int get_layer_texture_mask_mix_operation(int layer) {
	switch (layer) {
		case 1:
			return layer_1_texture_masks_mix_operation;
		case 2:
			return layer_2_texture_masks_mix_operation;
		case 3:
			return layer_3_texture_masks_mix_operation;
	}
}

int get_layer_directional_mask_mode(int layer) {
	switch (layer) {
		case 1:
			return layer_1_directional_mask_mode;
		case 2:
			return layer_2_directional_mask_mode;
		case 3:
			return layer_3_directional_mask_mode;
	}
}

int get_layer_directional_mask_space(int layer) {
	switch (layer) {
		case 1:
			return layer_1_directional_mask_space;
		case 2:
			return layer_2_directional_mask_space;
		case 3:
			return layer_3_directional_mask_space;
	}
}

float get_layer_directional_mask_color_ramp_value(int layer, float factor) {
	switch (layer) {
		case 1:
			vec2 color_ramp_factor = texture(layer_1_directional_mask_color_ramp, vec2((factor * 0.95) + 0.025)).ra;
			return mix(factor, color_ramp_factor.x, color_ramp_factor.y);
		case 2:
			vec2 color_ramp_factor = texture(layer_2_directional_mask_color_ramp, vec2((factor * 0.95) + 0.025)).ra;
			return mix(factor, color_ramp_factor.x, color_ramp_factor.y);
		case 3:
			vec2 color_ramp_factor = texture(layer_3_directional_mask_color_ramp, vec2((factor * 0.95) + 0.025)).ra;
			return mix(factor, color_ramp_factor.x, color_ramp_factor.y);
	}
}

int get_layer_positional_mask_mode(int layer) {
	switch (layer) {
		case 1:
			return layer_1_positional_mask_mode;
		case 2:
			return layer_2_positional_mask_mode;
		case 3:
			return layer_3_positional_mask_mode;
	}
}

int get_layer_positional_mask_axis(int layer) {
	switch (layer) {
		case 1:
			return layer_1_positional_mask_axis;
		case 2:
			return layer_2_positional_mask_axis;
		case 3:
			return layer_3_positional_mask_axis;
	}
}

float get_layer_positional_mask_min(int layer) {
	switch (layer) {
		case 1:
			return layer_1_positional_mask_min;
		case 2:
			return layer_2_positional_mask_min;
		case 3:
			return layer_3_positional_mask_min;
	}
}

float get_layer_positional_mask_max(int layer) {
	switch (layer) {
		case 1:
			return layer_1_positional_mask_max;
		case 2:
			return layer_2_positional_mask_max;
		case 3:
			return layer_3_positional_mask_max;
	}
}

float get_layer_positional_mask_color_ramp_value(int layer, float factor) {
	switch (layer) {
		case 1:
			vec2 color_ramp_factor = texture(layer_1_positional_mask_color_ramp, vec2(factor, 0.0)).ra;
			return mix(factor, color_ramp_factor.x, color_ramp_factor.y);
		case 2:
			vec2 color_ramp_factor = texture(layer_2_positional_mask_color_ramp, vec2(factor, 0.0)).ra;
			return mix(factor, color_ramp_factor.x, color_ramp_factor.y);
		case 3:
			vec2 color_ramp_factor = texture(layer_3_positional_mask_color_ramp, vec2(factor, 0.0)).ra;
			return mix(factor, color_ramp_factor.x, color_ramp_factor.y);
	}
}

//======================================================================




float get_texture_mask_for_layer(int layer, vec2 uv) {
	float texture_mask_mix;

	vec4 texture_mask_A_texture = get_layer_texture_mask_texture(layer, 0, uv);
	vec4 texture_mask_B_texture = get_layer_texture_mask_texture(layer, 1, uv);

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
	switch (layer) {
		case 1:
			switch (layer_1_vertex_color_mask_mode) {
				case 0:
					return 0.0;
				case 1:
					return texture(layer_1_vertex_color_mask_color_ramp, vec2(clamp(vertex_color.r, 0.01, 0.99), 0.2)).r * vertex_color.r;
				case 2:
					return texture(layer_1_vertex_color_mask_color_ramp, vec2(clamp(vertex_color.g, 0.01, 0.99), 0.2)).r * vertex_color.g;
				case 3:
					return texture(layer_1_vertex_color_mask_color_ramp, vec2(clamp(vertex_color.b, 0.01, 0.99), 0.2)).r * vertex_color.b;
			}
		case 2:
			switch (layer_2_vertex_color_mask_mode) {
				case 0:
					return 0.0;
				case 1:
					return texture(layer_2_vertex_color_mask_color_ramp, vec2(clamp(vertex_color.r, 0.01, 0.99), 0.2)).r * vertex_color.r;
				case 2:
					return texture(layer_2_vertex_color_mask_color_ramp, vec2(clamp(vertex_color.g, 0.01, 0.99), 0.2)).r * vertex_color.g;
				case 3:
					return texture(layer_2_vertex_color_mask_color_ramp, vec2(clamp(vertex_color.b, 0.01, 0.99), 0.2)).r * vertex_color.b;
			}
		case 3:
			switch (layer_3_vertex_color_mask_mode) {
				case 0:
					return 0.0;
				case 1:
					return texture(layer_3_vertex_color_mask_color_ramp, vec2(clamp(vertex_color.r, 0.01, 0.99), 0.2)).r * vertex_color.r;
				case 2:
					return texture(layer_3_vertex_color_mask_color_ramp, vec2(clamp(vertex_color.g, 0.01, 0.99), 0.2)).r * vertex_color.g;
				case 3:
					return texture(layer_3_vertex_color_mask_color_ramp, vec2(clamp(vertex_color.b, 0.01, 0.99), 0.2)).r * vertex_color.b;
			}

	};
}

float get_resulting_mask_for_layer(int layer, vec2 uv, vec3 local_surface_normal, vec3 global_surface_normal, vec3 local_vertex_position, vec3 global_vertex_position) {
	float step_1_mix = clamp((get_texture_mask_for_layer(layer, uv) * float(get_layer_mask_mixing_step(layer, 1) == 1) + get_directional_mask_for_layer(layer, local_surface_normal, global_surface_normal) * float(get_layer_mask_mixing_step(layer, 2) == 1) + get_positional_mask_for_layer(layer, local_vertex_position, global_vertex_position) * float(get_layer_mask_mixing_step(layer, 3) == 1) + get_vertex_color_mask_for_layer(layer) * float(get_layer_mask_mixing_step(layer, 4) == 1)), 0.0, 1.0);

	float step_2_mix = clamp((get_texture_mask_for_layer(layer, uv) * float(get_layer_mask_mixing_step(layer, 1) == 2) + get_directional_mask_for_layer(layer, local_surface_normal, global_surface_normal) * float(get_layer_mask_mixing_step(layer, 2) == 2) + get_positional_mask_for_layer(layer, local_vertex_position, global_vertex_position) * float(get_layer_mask_mixing_step(layer, 3) == 2) + get_vertex_color_mask_for_layer(layer) * float(get_layer_mask_mixing_step(layer, 4) == 2)), 0.0, 1.0);
	switch (get_layer_step_mixing_operation(layer, 2)) {
		case 0:
			step_2_mix = clamp(step_1_mix + step_2_mix, 0.0, 1.0);
			break;
		case 1:
			step_2_mix = clamp(step_1_mix - step_2_mix, 0.0, 1.0);
			break;
		case 2:
			step_2_mix = clamp(step_1_mix * step_2_mix, 0.0, 1.0);
			break;
	}

	float step_3_mix = clamp((get_texture_mask_for_layer(layer, uv) * float(get_layer_mask_mixing_step(layer, 1) == 3) + get_directional_mask_for_layer(layer, local_surface_normal, global_surface_normal) * float(get_layer_mask_mixing_step(layer, 2) == 3) + get_positional_mask_for_layer(layer, local_vertex_position, global_vertex_position) * float(get_layer_mask_mixing_step(layer, 3) == 3) + get_vertex_color_mask_for_layer(layer) * float(get_layer_mask_mixing_step(layer, 4) == 3)), 0.0, 1.0);
	switch (get_layer_step_mixing_operation(layer, 3)) {
		case 0:
			step_3_mix = clamp(step_2_mix + step_3_mix, 0.0, 1.0);
			break;
		case 1:
			step_3_mix = clamp(step_2_mix - step_3_mix, 0.0, 1.0);
			break;
		case 2:
			step_3_mix = clamp(step_2_mix * step_3_mix, 0.0, 1.0);
			break;
	}

	float step_4_mix = clamp((get_texture_mask_for_layer(layer, uv) * float(get_layer_mask_mixing_step(layer, 1) == 4) + get_directional_mask_for_layer(layer, local_surface_normal, global_surface_normal) * float(get_layer_mask_mixing_step(layer, 2) == 4) + get_positional_mask_for_layer(layer, local_vertex_position, global_vertex_position) * float(get_layer_mask_mixing_step(layer, 3) == 4) + get_vertex_color_mask_for_layer(layer) * float(get_layer_mask_mixing_step(layer, 4) == 4)), 0.0, 1.0);
	switch (get_layer_step_mixing_operation(layer, 4)) {
		case 0:
			step_4_mix = clamp(step_3_mix + step_4_mix, 0.0, 1.0);
			break;
		case 1:
			step_4_mix = clamp(step_3_mix - step_4_mix, 0.0, 1.0);
			break;
		case 2:
			step_4_mix = clamp(step_3_mix * step_4_mix, 0.0, 1.0);
			break;
	}

	//return step_3_mix;
	return get_layer_mask_post_color_ramp_value(layer, clamp(step_4_mix * get_layer_mask_amplification(layer), 0.0, 1.0) * 0.9 + 0.02) * step_4_mix;
}

//vec3 normal_from_mask(vec2 uv, int layer) {
	//switch (layer) {
		//case 1:
			//float val = get_resulting_mask_for_layer(1, uv);
			//float val_right = get_resulting_mask_for_layer(1, uv + vec2(1.0 / 1024.0, 0));
			//float val_up = get_resulting_mask_for_layer(1, uv + vec2(0, 1.0 / 1204.0));
//
			//return normalize(vec3(val - val_right, 0.5, val - val_up));
	//}
//}

void vertex() {
	local_vertex_normal = NORMAL.rgb;
	global_vertex_normal = local_vertex_normal * MODEL_NORMAL_MATRIX;
	local_vertex_pos = VERTEX.xyz;
	global_vertex_pos = (vec4(local_vertex_normal, 1.0) * MODEL_MATRIX).xyz;
}

void fragment() {
	vertex_color = COLOR.rgb;

	vec4 layer_base_albedo_texture = texture(layer_base_albedo, (UV + layer_base_uv_offset) * layer_base_uv_scale);
	float layer_base_occlusion_factor = texture(layer_base_occlusion_map, (UV + layer_base_uv_offset) * layer_base_uv_scale).r;
	float layer_base_roughness_factor = texture(layer_base_roughness_map, (UV + layer_base_uv_offset) * layer_base_uv_scale).r;
	float layer_base_metallic_factor = texture(layer_base_metallic_map, (UV + layer_base_uv_offset) * layer_base_uv_scale).r;
	vec3 layer_base_normal_texture = texture(layer_base_normal, (UV + layer_base_uv_offset) * layer_base_uv_scale).rgb;

	vec4 layer_1_albedo_texture = texture(layer_1_albedo, (UV + layer_1_uv_offset) * layer_1_uv_scale);
	vec2 layer_1_occlusion_factor = texture(layer_1_occlusion_map, (UV + layer_1_uv_offset) * layer_1_uv_scale).ra * float(layer_1_orm_mode) + texture(layer_1_orm_map, UV * layer_1_uv_scale).ra * (1.0 - float(layer_1_orm_mode));
	vec2 layer_1_roughness_factor = texture(layer_1_roughness_map, (UV + layer_1_uv_offset) * layer_1_uv_scale).ra * float(layer_1_orm_mode) + texture(layer_1_orm_map, UV * layer_1_uv_scale).ga * (1.0 - float(layer_1_orm_mode));;
	vec2 layer_1_metallic_factor = texture(layer_1_metallic_map, (UV + layer_1_uv_offset) * layer_1_uv_scale).ra * float(layer_1_orm_mode) + texture(layer_1_orm_map, UV * layer_1_uv_scale).ba * (1.0 - float(layer_1_orm_mode));
	vec3 layer_1_normal_texture = texture(layer_1_normal, (UV + layer_1_uv_offset) * layer_1_uv_scale).rgb;

	vec4 layer_2_albedo_texture = texture(layer_2_albedo, (UV + layer_2_uv_offset) * layer_2_uv_scale);
	vec2 layer_2_occlusion_factor = texture(layer_2_occlusion_map, (UV + layer_2_uv_offset) * layer_2_uv_scale).ra * float(layer_2_orm_mode) + texture(layer_2_orm_map, UV * layer_2_uv_scale).ra * (1.0 - float(layer_2_orm_mode));
	vec2 layer_2_roughness_factor = texture(layer_2_roughness_map, (UV + layer_2_uv_offset) * layer_2_uv_scale).ra * float(layer_2_orm_mode) + texture(layer_2_orm_map, UV * layer_2_uv_scale).ga * (1.0 - float(layer_2_orm_mode));;
	vec2 layer_2_metallic_factor = texture(layer_2_metallic_map, (UV + layer_2_uv_offset) * layer_2_uv_scale).ra * float(layer_2_orm_mode) + texture(layer_2_orm_map, UV * layer_2_uv_scale).ba * (1.0 - float(layer_2_orm_mode));
	vec3 layer_2_normal_texture = texture(layer_2_normal, (UV + layer_2_uv_offset) * layer_2_uv_scale).rgb;

	vec4 layer_3_albedo_texture = texture(layer_3_albedo, (UV + layer_3_uv_offset) * layer_3_uv_scale);
	vec2 layer_3_occlusion_factor = texture(layer_3_occlusion_map, (UV + layer_3_uv_offset) * layer_3_uv_scale).ra * float(layer_3_orm_mode) + texture(layer_3_orm_map, UV * layer_3_uv_scale).ra * (1.0 - float(layer_3_orm_mode));
	vec2 layer_3_roughness_factor = texture(layer_3_roughness_map, (UV + layer_3_uv_offset) * layer_3_uv_scale).ra * float(layer_3_orm_mode) + texture(layer_3_orm_map, UV * layer_3_uv_scale).ga * (1.0 - float(layer_3_orm_mode));;
	vec2 layer_3_metallic_factor = texture(layer_3_metallic_map, (UV + layer_3_uv_offset) * layer_3_uv_scale).ra * float(layer_3_orm_mode) + texture(layer_3_orm_map, UV * layer_3_uv_scale).ba * (1.0 - float(layer_3_orm_mode));
	vec3 layer_3_normal_texture = texture(layer_3_normal, (UV + layer_3_uv_offset) * layer_3_uv_scale).rgb;

	//vec3 layer_3_albedo_texture = texture(layer_3_albedo, UV * layer_3_uv_scale).rgb;

	vec4 albedo_mix = layer_base_albedo_texture;
	float occlusion_mix = layer_base_occlusion_factor;
	float roughness_mix = layer_base_roughness_factor;
	float metallic_mix = layer_base_metallic_factor;
	vec3 normal_mix = layer_base_normal_texture;

	if (layer_1_enabled == true) {


		float layer_1_mask_factor = get_resulting_mask_for_layer(1, (UV + layer_1_uv_offset) * layer_1_uv_scale, local_vertex_normal, global_vertex_normal, local_vertex_pos, global_vertex_pos);
		albedo_mix = mix(albedo_mix, layer_1_albedo_texture, layer_1_mask_factor * layer_1_albedo_texture.a);
		albedo_mix = mix(albedo_mix, vec4(layer_1_mask_factor), float(layer_1_consolidate_masks));

		occlusion_mix = mix(occlusion_mix, layer_1_occlusion_factor.x, layer_1_mask_factor * layer_1_occlusion_factor.y);
		roughness_mix = mix(roughness_mix, layer_1_roughness_factor.x, layer_1_mask_factor * layer_1_roughness_factor.y);
		metallic_mix = mix(metallic_mix, layer_1_metallic_factor.x, layer_1_mask_factor * layer_1_metallic_factor.y);
		normal_mix = mix(normal_mix, layer_1_normal_texture, layer_1_mask_factor);
	}

	if (layer_2_enabled == true) {


		float layer_2_mask_factor = get_resulting_mask_for_layer(2, (UV + layer_2_uv_offset) * layer_2_uv_scale, local_vertex_normal, global_vertex_normal, local_vertex_pos, global_vertex_pos);
		albedo_mix = mix(albedo_mix, layer_2_albedo_texture, layer_2_mask_factor * layer_2_albedo_texture.a);
		albedo_mix = mix(albedo_mix, vec4(layer_2_mask_factor), float(layer_2_consolidate_masks));

		occlusion_mix = mix(occlusion_mix, layer_2_occlusion_factor.x, layer_2_mask_factor * layer_2_occlusion_factor.y);
		roughness_mix = mix(roughness_mix, layer_2_roughness_factor.x, layer_2_mask_factor * layer_2_roughness_factor.y);
		metallic_mix = mix(metallic_mix, layer_2_metallic_factor.x, layer_2_mask_factor * layer_2_metallic_factor.y);
		normal_mix = mix(normal_mix, layer_2_normal_texture, layer_2_mask_factor);
	}

	if (layer_3_enabled == true) {


		float layer_3_mask_factor = get_resulting_mask_for_layer(3, (UV + layer_3_uv_offset) * layer_3_uv_scale, local_vertex_normal, global_vertex_normal, local_vertex_pos, global_vertex_pos);
		albedo_mix = mix(albedo_mix, layer_3_albedo_texture, layer_3_mask_factor * layer_3_albedo_texture.a);
		albedo_mix = mix(albedo_mix, vec4(layer_3_mask_factor), float(layer_3_consolidate_masks));

		occlusion_mix = mix(occlusion_mix, layer_3_occlusion_factor.x, layer_3_mask_factor * layer_3_occlusion_factor.y);
		roughness_mix = mix(roughness_mix, layer_3_roughness_factor.x, layer_3_mask_factor * layer_3_roughness_factor.y);
		metallic_mix = mix(metallic_mix, layer_3_metallic_factor.x, layer_3_mask_factor * layer_3_metallic_factor.y);
		normal_mix = mix(normal_mix, layer_3_normal_texture, layer_3_mask_factor);
	}
	ALBEDO = albedo_mix.rgb;
	//ALBEDO = vec3(get_positional_mask_for_layer(1, local_vertex_pos, global_vertex_pos));
	//ALBEDO = vec3(get_directional_mask_for_layer(1, local_vertex_normal, global_vertex_normal));
	//ALBEDO = vec3(get_resulting_mask_for_layer(1, UV, local_vertex_normal, global_vertex_normal, local_vertex_pos, global_vertex_pos));
	//ALBEDO = vec3(get_vertex_color_mask_for_layer(1));
	ROUGHNESS = roughness_mix;
	METALLIC = metallic_mix;

	NORMAL_MAP = normal_mix;

	//ALBEDO = global_vertex_normal.rgb;
	//ALPHA = 1.0;
}