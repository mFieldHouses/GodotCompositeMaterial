@tool
extends Resource
class_name CompositeMaterialLayer

signal parameter_changed

@export var layer_name : String

@export_group("Vertex Displacement", "vertex")
@export_enum("Disabled", "Normal") var vertex_displacement_mode := 0
@export var vertex_displacement_scale := -1.0;
@export var vertex_displacement_map : Texture2D;

@export var enabled := true:
	set(x):
		enabled = x
		emit_changed()

@export_range(0.0, 1.0, 0.01, "or_greater", "hide_control") var lod_level : float = 0.0

@export var albedo : Texture2D:
	set(x):
		albedo = x
		emit_changed()

@export var normal : Texture2D;
@export var propagate_normals := false:
	set(x):
		propagate_normals = x
		emit_changed()

@export_group("UV1", "uv1")

@export_enum("From Mesh", "Triplanar") var uv1_mode = 0
@export_enum("Local", "Global") var uv1_triplanar_mode = 0

@export var uv1_scale := Vector2(1.0, 1.0);
@export var uv1_offset := Vector2(0.0, 0.0);
@export var uv1_offset_map : Texture2D;
@export var uv1_offset_map_scale := Vector2(1.0, 1.0);
@export var uv1_offset_map_factor := 1.0:
	set(x):
		uv1_offset_map_factor = x
		emit_changed()

@export_group("UV2", "uv2")

@export_enum("From Mesh", "Triplanar") var uv2_mode = 0
@export_enum("Local", "Global") var uv2_triplanar_mode = 0

@export var uv2_scale := Vector2(1.0, 1.0);
@export var uv2_offset := Vector2(0.0, 0.0);
@export var uv2_offset_map : Texture2D;
@export var uv2_offset_map_scale := Vector2(1.0, 1.0);
@export var uv2_offset_map_factor := 1.0:
	set(x):
		uv2_offset_map_factor = x
		emit_changed()

@export_group("UV Assignment")
@export_enum("UV1", "UV2") var normal_map_UV_assignment := 0;
@export_enum("UV1", "UV2") var albedo_map_UV_assignment := 0;
@export_enum("UV1", "UV2") var occlusion_map_UV_assignment := 0;
@export_enum("UV1", "UV2") var roughness_map_UV_assignment := 0;
@export_enum("UV1", "UV2") var metallic_map_UV_assignment := 0;
@export_enum("UV1", "UV2") var UV_offset_map_UV_assignment := 0;
@export_enum("UV1", "UV2") var texture_mask_A_UV_assignment := 1;
@export_enum("UV1", "UV2") var texture_mask_B_UV_assignment := 1;
@export_enum("UV1", "UV2") var UV_mask_UV_assignment := 0;

@export_group("ORM")
@export_enum("Single map", "Seperate maps") var orm_mode := 0;
@export var orm_map : Texture2D:
	set(x):
		orm_map = x
		emit_changed()
@export var occlusion_map : Texture2D:
	set(x):
		occlusion_map = x
		emit_changed()
@export var roughness_map : Texture2D:
	set(x):
		roughness_map = x
		emit_changed()
@export var metallic_map : Texture2D:
	set(x):
		metallic_map = x
		emit_changed()

@export_group("Masking")
@export var consolidate_masks := false;
@export_range(0.0, 10.0) var mask_amplification := 1.0;
@export_enum("Add", "Subtract", "Multiply") var step_2_mixing_operation := 0;
@export_range(0.0, 1.0) var step_2_mixing_threshold := 0.0;
@export_enum("Add", "Subtract", "Multiply") var step_3_mixing_operation := 0;
@export_range(0.0, 1.0) var step_3_mixing_threshold := 0.0;
@export_enum("Add", "Subtract", "Multiply") var step_4_mixing_operation := 0;
@export_range(0.0, 1.0) var step_4_mixing_threshold := 0.0;
@export_enum("Add", "Subtract", "Multiply") var step_5_mixing_operation := 0;
@export_range(0.0, 1.0) var step_5_mixing_threshold := 0.0;
@export_enum("Add", "Subtract", "Multiply") var step_6_mixing_operation := 0;
@export_range(0.0, 1.0) var step_6_mixing_threshold := 0.0;
@export_subgroup("Post")
@export var post_color_ramp : GradientTexture1D:
	set(x):
		post_color_ramp = x
		emit_changed()
@export_enum("None", "Drip", "Expand-Blur") var post_effect := 0;
@export_range(0.0, 1.0) var post_effect_parameter_1 := 0.1;
@export var post_effect_parameter_2 := 0.0;
@export var post_effect_parameter_3 = 0.0;

@export_group("Texture Masks")
@export var texture_mask_A_enabled := true;
@export var texture_mask_A : Texture2D
@export var texture_mask_A_color_ramp : Texture2D
@export var texture_mask_B_enabled := false;
@export var texture_mask_B : Texture2D
@export var texture_mask_B_color_ramp : Texture2D

@export_enum("Add", "Subtract", "Multiply") var texture_masks_mix_operation := 0;

@export_enum("A - B", "B - A") var texture_masks_subtraction_order := 0;
@export_enum("Step 1:1", "Step 2:2", "Step 3:3", "Step 4:4", "Step 5:5", "Step 6:6") var texture_masks_mixing_step := 1;

@export_group("Directional Mask")
@export_enum("Disabled", "X", "X+", "X-", "Y", "Y+", "Y-", "Z", "Z+", "Z-") var directional_mask_mode := 0;
@export_enum("Global", "Local") var directional_mask_space := 0;
@export var directional_mask_color_ramp : GradientTexture1D:
	set(x):
		directional_mask_color_ramp = x
		emit_changed()
@export_enum("Step 1:1", "Step 2:2", "Step 3:3", "Step 4:4", "Step 5:5", "Step 6:6") var directional_mask_mixing_step := 2;

@export_group("Positional Mask")
@export_enum("Disabled", "Local", "Global") var positional_mask_mode := 0;
@export_enum("X", "Y", "Z") var positional_mask_axis := 1;
@export var positional_mask_color_ramp : GradientTexture1D:
	set(x):
		positional_mask_color_ramp = x
		emit_changed()
@export var positional_mask_max := 1.0;
@export var positional_mask_min := -1.0;
@export_enum("Step 1:1", "Step 2:2", "Step 3:3", "Step 4:4", "Step 5:5", "Step 6:6") var positional_mask_mixing_step := 3;

@export_group("Vertex Color Mask")
@export_enum("Disabled", "Red", "Green", "Blue", "Specific Color") var vertex_color_mask_mode := 0;
@export var vertex_color_mask_target_color : Color
@export var vertex_color_mask_color_ramp : GradientTexture1D:
	set(x):
		vertex_color_mask_color_ramp = x
		emit_changed()
@export_enum("Step 1:1", "Step 2:2", "Step 3:3", "Step 4:4", "Step 5:5", "Step 6:6") var vertex_color_mask_mixing_step := 4;

@export_group("Normal Map Slope Mask")
@export_enum("Disabled", "Pre-Mask", "Post-Mask") var normal_map_slope_mask_mode := 0;
@export_enum("Previous Layer", "Current Layer") var normal_map_slope_mask_source := 0;
@export var normal_map_slope_mask_color_ramp : GradientTexture1D:
	set(x):
		normal_map_slope_mask_color_ramp = x
		emit_changed()
@export_enum("Step 1:1", "Step 2:2", "Step 3:3", "Step 4:4", "Step 5:5", "Step 6:6") var normal_map_slope_mask_mixing_step := 5;

@export_group("UV Mask")
@export var UV_mask_enabled := false;
@export var UV_mask_X_min = 0.0;
@export var UV_mask_X_max = 1.0;
@export var UV_mask_X_color_ramp : GradientTexture1D:
	set(x):
		UV_mask_X_color_ramp = x
		emit_changed()
		
@export var UV_mask_Y_min = 0.0;
@export var UV_mask_Y_max = 1.0;
@export var UV_mask_Y_color_ramp : GradientTexture1D:
	set(x):
		UV_mask_Y_color_ramp = x
		emit_changed()
@export_enum("Add", "Subtract", "Multiply") var UV_mask_XY_mixing_operation := 0;
@export_enum("X-Y", "Y-X") var UV_mask_XY_mixing_order := 0;
@export_enum("Step 1:1", "Step 2:2", "Step 3:3", "Step 4:4", "Step 5:5", "Step 6:6") var UV_mask_mixing_step := 6;
