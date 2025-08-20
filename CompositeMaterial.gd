@tool
extends ShaderMaterial
class_name CompositeMaterial

signal finish_building

@export var layers : Array[CompositeMaterialLayer]: #Array of resources storing parameters of seperate layers
	set(x):
		previous_layers_size = layers.size()
		layers = x
		build_material()

var previous_layers_size : int = 0
	
enum layer_index {LAYER_A = 0, LAYER_B = 1, LAYER_C = 2}

#@export_tool_button("Export Material", "File") var export_material_func = export_material
#@export_tool_button("Import Material", "File") var import_material_func = export_material

#@export var base_albedo : Texture2D
#@export var base_normal_map : Texture2D
#@export_enum("Single Map", "Seperate Maps") var orm_mode : int = 0
#@export var base_orm_map : Texture2D
#@export var base_occlusion_map : Texture2D
#@export var base_roughness_map : Texture2D
#@export var base_metallic_map : Texture2D
var export_path_dialog : EditorFileDialog

@export var offset_noise_by_world_transform : bool = false
@export var enable_alpha : bool = false: ##Enable this if you want to have partially transparent materials. Can take a big impact on perfomance if used excessively.
	set(x):
		enable_alpha = x
		build_material()
	
func build_material(shaded : bool = true) -> void:
	print("rebuilding material " + resource_path)
	if previous_layers_size != layers.size():
		var new_shader = Shader.new()
		new_shader.set_code(compose_shader_code(layers.size(), shaded))
		shader = new_shader
		
	clear_all_shader_parameters()
	
	#EditorInterface.get_editor_toaster().push_toast("Building material...")
	
	var layer_idx : int = 0
	for layer_config in layers:
		if layer_config == null:
			continue
		
		for connected_signal in layer_config.get_incoming_connections():
			layer_config.disconnect(connected_signal.signal.get_name(), connected_signal.callable.get_method())
		
		if !layer_config.is_connected("changed", update_config):
			layer_config.changed.connect(update_config.bind(layer_config))
		layer_config.emit_changed()
		layer_idx += 1
			
	emit_changed()
	print("Done building")
	finish_building.emit()
	#EditorInterface.get_editor_toaster().push_toast("Done building material!")

#func export_material():
	#print("export")
	#export_path_dialog.popup_centered()
	#
	#export_path_dialog.file_selected.connect(func assign_path(path): create_cpm_file(path))
#
#func create_cpm_file(path : String) -> void:
	#var writer = ZIPPacker.new()
	#writer.open(path)
	#writer.start_file("hello.txt")
	#writer.write_file("Hello World".to_utf8_buffer())
	#writer.close_file()
#
	#writer.close()

func update_config(new_config : CompositeMaterialLayer):
	var layer_idx = layers.find(new_config) + 1
	print("update config for layer ", layer_idx)
	for property in new_config.get_property_list():
		if new_config.get(property.name) != null:
			set_shader_parameter("layer_" + str(layer_idx) +"_" + property.name, new_config.get(property.name))

func clear_all_shader_parameters():
	for param in shader.get_shader_uniform_list():
		set_shader_parameter(param.name, null)

func compose_shader_code(layer_num: int, shaded: bool) -> String: ##Returns CompositeMaterial shader code containing [param size] layers.
	var compose_sc = func compose_simple_sc(line_base : String, sc_size : int) -> String:
		var result : String
		for i in sc_size:
			var layer_idx = i + 1
			result += "case " + str(layer_idx) + ": " + line_base.replace("%s", str(layer_idx)) + " "
				
		return result
	
	var strings = load("res://addons/CompositeMaterial/shader_composition_strings.gd")
	
	var result : String
	if shaded:
		result = strings.render_mode_shaded_string + strings.base_string
	else:
		result = strings.render_mode_unshaded_string + strings.base_string
	
	var parameters : String
	var fragment_snippets : String
	
	var start_time = Time.get_ticks_msec()
	
	for i in layer_num:
		var layer_idx : int = i + 1
		
		parameters += (strings.parameters_string.replace("%s", str(layer_idx))) + "\n"
		fragment_snippets += (strings.fragment_snippet_string.replace("%s", str(layer_idx))) + "\n"
		
	result = result.replace("%parameters", parameters)
	result = result.replace("%layer_fragment_snippets", fragment_snippets)
	
	result = result.replace("%get_layer_enabled_sc", compose_sc.call(strings.get_layer_enabled_string, layer_num))
	result = result.replace("%get_layer_uv_offset_sc", compose_sc.call(strings.get_layer_uv_offset_string, layer_num))
	result = result.replace("%get_layer_uv_sc", compose_sc.call(strings.get_layer_uv_string, layer_num))
	result = result.replace("%get_layer_map_uv_index_sc", compose_sc.call(strings.get_layer_map_uv_index_string, layer_num))
	result = result.replace("%get_layer_mask_mixing_step_sc", compose_sc.call(strings.get_layer_mask_mixing_step_string, layer_num))
	result = result.replace("%get_layer_step_mixing_operation_sc", compose_sc.call(strings.get_layer_step_mixing_operation_string, layer_num))
	result = result.replace("%get_layer_step_mixing_threshold_sc", compose_sc.call(strings.get_layer_step_mixing_threshold_string, layer_num))
	result = result.replace("%get_layer_mask_amplification_sc", compose_sc.call(strings.get_layer_mask_amplification_string, layer_num))
	result = result.replace("%get_layer_mask_post_color_ramp_value_sc", compose_sc.call(strings.get_layer_mask_post_color_ramp_value_string, layer_num))
	result = result.replace("%get_layer_post_effect_sc", compose_sc.call(strings.get_layer_post_effect_string, layer_num))
	result = result.replace("%get_layer_post_effect_parameter_sc", compose_sc.call(strings.get_layer_post_effect_parameter_string, layer_num))
	result = result.replace("%get_layer_texture_mask_texture_sc", compose_sc.call(strings.get_layer_texture_mask_texture_string, layer_num))
	result = result.replace("%get_layer_texture_mask_enabled_sc", compose_sc.call(strings.get_layer_texture_mask_enabled_string, layer_num))
	result = result.replace("%get_layer_texture_masks_subtraction_order_sc", compose_sc.call(strings.get_layer_texture_masks_subtraction_order_string, layer_num))
	result = result.replace("%get_layer_texture_mask_mix_operation_sc", compose_sc.call(strings.get_layer_texture_mask_mix_operation_string, layer_num))
	result = result.replace("%get_layer_directional_mask_mode_sc", compose_sc.call(strings.get_layer_directional_mask_mode_string, layer_num))
	result = result.replace("%get_layer_directional_mask_space_sc", compose_sc.call(strings.get_layer_directional_mask_space_string, layer_num))
	result = result.replace("%get_layer_directional_mask_color_ramp_value_sc", compose_sc.call(strings.get_layer_directional_mask_color_ramp_value_string, layer_num))
	result = result.replace("%get_layer_positional_mask_mode_sc", compose_sc.call(strings.get_layer_positional_mask_mode_string, layer_num))
	result = result.replace("%get_layer_positional_mask_axis_sc", compose_sc.call(strings.get_layer_positional_mask_axis_string, layer_num))
	result = result.replace("%get_layer_positional_mask_min_sc", compose_sc.call(strings.get_layer_positional_mask_min_string, layer_num))
	result = result.replace("%get_layer_positional_mask_max_sc", compose_sc.call(strings.get_layer_positional_mask_max_string, layer_num))
	result = result.replace("%get_layer_positional_mask_color_ramp_value_sc", compose_sc.call(strings.get_layer_positional_mask_color_ramp_value_string, layer_num))
	result = result.replace("%get_layer_vertex_color_mask_mode_sc", compose_sc.call(strings.get_layer_vertex_color_mask_mode_string, layer_num))
	result = result.replace("%get_layer_vertex_color_mask_color_ramp_value_sc", compose_sc.call(strings.get_layer_vertex_color_mask_color_ramp_value_string, layer_num))
	result = result.replace("%get_layer_normal_map_slope_mask_mode_sc", compose_sc.call(strings.get_layer_normal_map_slope_mask_mode_string, layer_num))
	result = result.replace("%get_normal_map_slope_mask_for_layer_sc", compose_sc.call(strings.get_normal_map_slope_mask_for_layer_string, layer_num))
	result = result.replace("%get_layer_normal_map_slope_mask_color_ramp_value_sc", compose_sc.call(strings.get_layer_normal_map_slope_mask_color_ramp_value_string, layer_num))
	result = result.replace("%get_layer_uv_mask_enabled_sc", compose_sc.call(strings.get_layer_UV_mask_enabled_string, layer_num))
	result = result.replace("%get_layer_uv_mask_mixing_operation_sc", compose_sc.call(strings.get_layer_UV_mask_mixing_operation_string, layer_num))
	result = result.replace("%get_layer_uv_mask_mixing_order_sc", compose_sc.call(strings.get_layer_UV_mask_mixing_order_string, layer_num))
	result = result.replace("%get_layer_uv_mask_color_ramp_value_sc", compose_sc.call(strings.get_layer_UV_mask_color_ramp_value_string, layer_num))
	result = result.replace("%get_layer_uv_mask_min_sc", compose_sc.call(strings.get_layer_UV_mask_min_string, layer_num))
	result = result.replace("%get_layer_uv_mask_max_sc", compose_sc.call(strings.get_layer_UV_mask_max_string, layer_num))
	
	var end_time = Time.get_ticks_msec()
	if Engine.is_editor_hint():
		EditorInterface.get_editor_toaster().push_toast("Rewrote shader in " + str(end_time - start_time) + "ms!")
	
	return result
