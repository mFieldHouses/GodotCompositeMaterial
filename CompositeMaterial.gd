@tool
extends ShaderMaterial
class_name CompositeMaterial

@export var layers : Array[CompositeMaterialLayer]: #Array of resources storing parameters of seperate layers
	set(x):
		layers = x
		build_material()

var material_units : Array[ShaderMaterial] #Array of actual materials being displayed. One material unit represents up to 3 layers.

var material_unit_configs

var layer_configs
	
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
	
func _init() -> void:
	if enable_alpha:
		shader = load("res://addons/CompositeMaterial/shaders/CompositeMaterialUnitAE.gdshader")
	else:
		shader = load("res://addons/CompositeMaterial/shaders/CompositeMaterialUnitAD.gdshader")
	#export_path_dialog = EditorFileDialog.new()
	#export_path_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	#export_path_dialog.current_file = "Unnamed Material.cpm"
	#
	#EditorInterface.get_base_control().add_child(export_path_dialog)
	
func build_material() -> void:
	print(compose_shader_code(layers.size()))
	
	print("rebuilding material")
	material_unit_configs = []
	material_units = []
	next_pass = null
	clear_all_shader_parameters()
	
	#EditorInterface.get_editor_toaster().push_toast("Building material...")

	for i in range(floori(layers.size() / 3.0) + 1):
		material_unit_configs.append([])
	
	var idx : int = 0
	for layer_config in layers:
		if layer_config != null:
			material_unit_configs[floori(idx / 3.0)].append(layer_config)
			
		idx += 1
	
	#print(material_unit_configs)
	
	var unit_idx : int = 0
	var previous_material : ShaderMaterial
	for unit_config in material_unit_configs:
		if unit_config == []:
			break
		
		var unit_material_instance
		if unit_idx == 0:
			unit_material_instance = self
			layer_configs = unit_config
		else:
			unit_material_instance = CompositeMaterialLayerShaderMaterial.create(unit_config, true)
			previous_material.next_pass = unit_material_instance
			
		material_units.append(unit_material_instance)
		previous_material = unit_material_instance
		
		var layer_idx : int = 0
		for layer_config in unit_config:
			if !layer_config.is_connected("changed", update_unit_configuration):
				layer_config.changed.connect(update_unit_configuration.bind(unit_idx, layer_idx))
			update_unit_configuration(unit_idx, layer_idx)
			layer_idx += 1
		unit_idx += 1
	
	print(material_units)
	print(self.shader)
			
	emit_changed()
	#EditorInterface.get_editor_toaster().push_toast("Done building material!")

func update_unit_configuration(unit_index : int, layer_index : int):
	material_units[unit_index].update_config(material_unit_configs[unit_index][layer_index], layer_index)


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

#This function is necessary to have the base class also act as a material unit, improving performance because we'll need less passes and thus less draw calls
func update_config(new_config : CompositeMaterialLayer, layer_idx : layer_index):
	print("update config")
	layer_configs[layer_idx] = new_config
	for property in new_config.get_property_list():
		if layer_configs[layer_idx].get(property.name) != null:
			set_shader_parameter(get_layer_prefix(layer_idx) + property.name, layer_configs[layer_idx].get(property.name))


func get_layer_prefix(layer_idx : layer_index) -> String:
	match layer_idx:
		layer_index.LAYER_A:
			return "layer_A_"
		layer_index.LAYER_B:
			return "layer_B_"
		layer_index.LAYER_C:
			return "layer_C_"
		_:
			return ""

func clear_all_shader_parameters():
	for param in shader.get_shader_uniform_list():
		set_shader_parameter(param.name, null)

func compose_shader_code(layer_num : int) -> String: ##Returns CompositeMaterial shader code containing [param size] layers.
	var compose_sc = func compose_simple_sc(line_base : String, sc_size : int) -> String:
		var result : String
		for i in sc_size:
			var layer_idx = i + 1
			result += "case " + str(layer_idx) + ": " + line_base % layer_idx + " "
				
		return result
	
	var strings = load("res://addons/CompositeMaterial/shader_composition_strings.gd")
	
	var result : String = strings.base_string
	
	var parameters : String
	var get_layer_uv_offset : String
	var get_layer_uv : String
	var get_layer_map_uv_index : String
	var get_layer_mask_mixing_step : String
	var get_layer_step_mixing_operation : String
	var get_layer_step_mixing_threshold : String
	var get_layer_mask_post_color_ramp_value : String
	var get_layer_post_effect_parameter : String
	var get_layer_texture_mask_texture : String
	var get_layer_texture_mask_enabled : String
	var get_layer_directional_mask_color_ramp_value : String
	var get_layer_positional_mask_color_ramp_value : String
	var get_layer_normal_map_slope_mask_color_ramp_value : String
	var get_layer_uv_mask_color_ramp_value : String
	var get_layer_uv_mask_min : String
	var get_layer_uv_mask_max : String
	
	for i in layer_num:
		var layer_idx : int = i + 1
		
		parameters += (strings.parameters_string.replace("%s", str(layer_idx))) + "\n"
	
	result = result.replace("%parameters", parameters)
	
	result = result.replace("%get_layer_enabled_sc", compose_sc.call("return layer_%s_enabled;", layer_num))
	result = result.replace("%get_layer_mask_amplification_sc", compose_sc.call("return layer_%s_mask_amplification;", layer_num))
	
	return result
