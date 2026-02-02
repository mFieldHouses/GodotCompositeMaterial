@tool
extends ShaderMaterial
class_name CompositeMaterial

signal finish_building

var requires_building : bool = false

@export_multiline var material_notes : String

@export var layers : Array[CompositeMaterialLayer]: #Array of resources storing parameters of seperate layers
	set(x):
		previous_layers_size = layers.size()
		layers = x
		build_material()
		
@export var autolock_material : bool = true ##Prevents the material from rewriting and recompiling the shader code automatically, reducing lag upon startup significantly.

@export_tool_button("Rebuild material", "Reload") var rebuild_action = build_material
@export_tool_button("Freeze") var freeze_action = freeze
@export_tool_button("Unfreeze") var unfreeze_action = unfreeze

var frozen : bool = false
var unfrozen_shader : Shader

var previous_layers_size : int = 0
	
var export_path_dialog : EditorFileDialog
	
func build_material(shaded : bool = true) -> void:
	if !Engine.is_editor_hint() and autolock_material:
		#print("skipping building material ", self)
		return
	
	#print("rebuilding material ", self)
	
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
	#print("Done building")
	finish_building.emit()
	#EditorInterface.get_editor_toaster().push_toast("Done building material!")

func freeze() -> void:
	frozen = true
	notify_property_list_changed()
	CPMFreezer.freeze_cpm(self)

func unfreeze() -> void:
	frozen = false
	notify_property_list_changed()
	shader = unfrozen_shader
	

func update_config(new_config : CompositeMaterialLayer):
	var layer_idx = layers.find(new_config) + 1
	#print("update config for layer ", layer_idx)
	for property in new_config.get_property_list():
		if new_config.get(property.name) != null:
			set_shader_parameter("layer_" + str(layer_idx) +"_" + property.name, new_config.get(property.name))

func clear_all_shader_parameters():
	for param in shader.get_shader_uniform_list():
		set_shader_parameter(param.name, null)

func compose_shader_code(layer_num: int, shaded: bool) -> String: ##Returns CompositeMaterial shader code containing [param size] layers.
	var strings = load("res://addons/CompositeMaterial/shader_composition_strings.gd")
	
	return strings.compose_shader_code(layer_num, shaded)
