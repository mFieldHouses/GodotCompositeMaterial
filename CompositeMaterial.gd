@tool
extends ShaderMaterial
class_name CompositeMaterial

@export var layers : Array[CompositeMaterialLayer]:
	set(x):
		layers = x
		build_material()

var material_units : Array[ShaderMaterial]

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
	print("rebuilding material")
	material_unit_configs = []
	material_units = []
	
	#EditorInterface.get_editor_toaster().push_toast("Building material...")

	for i in range(floori(layers.size() / 3.0) + 1):
		material_unit_configs.append([])
	
	var idx : int = 0
	for layer_config in layers:
		if layer_config != null:
			material_unit_configs[floori(idx / 3.0)].append(layer_config)
			
		idx += 1
	
	print(material_unit_configs)
	
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
			unit_material_instance = CompositeMaterialLayerShaderMaterial.create(unit_config, enable_alpha)
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
			#print("setting shader property ", get_layer_prefix(layer_idx) + property.name, " to ", layer_configs[layer_idx].get(property.name))

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
