@tool
extends CPMB_Vector3Value
class_name CPMB_TextureOutputConfiguration

@export var source_texture_configuration : CPMB_TextureConfiguration:
	set(x):
		source_texture_configuration = x
		
		is_variable = x.is_variable
		if !x.is_connected("is_variable_changed", _update_is_variable):
			x.is_variable_changed.connect(_update_is_variable)
		

@export_enum("RGB", "Alpha", "Mask") var output_channel : int = 0

func _init() -> void:
	#initialise_value()
	self.value = Vector3.INF
	is_descendant_resource = true

func _update_is_variable(state : bool) -> void:
	is_variable = state

func get_expression() -> String:
	print("get expression for channel ", output_channel)
	
	var _uniform_name : String
	var _suffix : String = ""
	if source_texture_configuration.filtering == 1:
		_uniform_name = "nearest_neighbor_textures"
		_suffix = "_nn"
	else:
		_uniform_name = "linear_textures"
		_suffix = "_ln"
	
	
	match output_channel:
		1:
			return "sample_texture%s(%s[%s], %s).a" % [_suffix, _uniform_name, source_texture_configuration.texture_index, source_texture_configuration.uv.get_expression()]
		2:
			return "sample_texture%s(%s[%s], %s).r" % [_suffix, _uniform_name, source_texture_configuration.texture_index, source_texture_configuration.uv.get_expression()]
		_:
			return "sample_texture%s(%s[%s], %s).rgb" % [_suffix, _uniform_name, source_texture_configuration.texture_index, source_texture_configuration.uv.get_expression()]
		
func get_source_resource() -> CPMB_Base:
	return source_texture_configuration

func _to_string() -> String:
	return "TextureOutputConfiguration:" + resource_scene_unique_id

func get_mapping_key() -> String:
	return "TextureOutputConfiguration"

func get_child_resources() -> Array[CPMB_Base]:
	return [source_texture_configuration.uv]

func on_mapped(resource_map : Dictionary[String, Array]) -> void:
	source_texture_configuration.on_mapped(resource_map)

func get_node_name() -> String:
	return "textures/TextureNode"

func get_input_port_resources() -> Dictionary[CPMB_Base, int]:
	return {
		source_texture_configuration.uv: 0
	}

func get_output_port_for_state() -> int:
	return output_channel
