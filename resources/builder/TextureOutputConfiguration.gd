@tool
extends CPMB_Vector3Value
class_name CPMB_TextureOutputConfiguration

@export var source_texture_configuration : CPMB_TextureConfiguration

@export_enum("RGB", "Alpha", "Mask") var output_channel : int = 0

func _init() -> void:
	#initialise_value()
	self.value = Vector3.INF
	is_descendant_resource = true

func get_expression() -> String:
	print("get expression for channel ", output_channel)
	
	var _uniform_name : String
	if source_texture_configuration.filtering == 1:
		_uniform_name = "nearest_neighbor_textures"
	else:
		_uniform_name = "linear_textures"
	
	match output_channel:
		1:
			return "texture(%s[%s], %s).a" % [_uniform_name, source_texture_configuration.texture_index, source_texture_configuration.uv.get_expression()]
		2:
			return "texture(%s[%s], %s).r" % [_uniform_name, source_texture_configuration.texture_index, source_texture_configuration.uv.get_expression()]
		_:
			return "texture(%s[%s], %s).rgb" % [_uniform_name, source_texture_configuration.texture_index, source_texture_configuration.uv.get_expression()]
		
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
