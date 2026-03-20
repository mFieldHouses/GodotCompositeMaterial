@tool
extends CPMB_Vector3Value
class_name CPMB_ColorRampOutputConfiguration

@export var source_color_ramp_configuration : CPMB_ColorRampConfiguration:
	set(x):
		source_color_ramp_configuration = x
		
		is_variable = x.is_variable
		if !x.is_connected("is_variable_changed", _update_is_variable):
			x.is_variable_changed.connect(_update_is_variable)

@export_enum("RGB", "Alpha", "Mask") var output_channel : int = 0

func _init() -> void:
	self.value = Vector3.INF
	is_descendant_resource = true

func _update_is_variable(state : bool) -> void:
	is_variable = state

func get_expression() -> String:
	match output_channel:
		1:
			return "get_color_ramp(%s, %s).a" % [source_color_ramp_configuration.texture_index, source_color_ramp_configuration.fac.get_expression()]
		2:
			return "get_color_ramp(%s, %s).r" % [source_color_ramp_configuration.texture_index, source_color_ramp_configuration.fac.get_expression()]
		_:
			return "get_color_ramp(%s, %s).rgb" % [source_color_ramp_configuration.texture_index, source_color_ramp_configuration.fac.get_expression()]

func get_mapping_key() -> String:
	return "ColorRampOutputConfiguration"

func _to_string() -> String:
	return "ColorRampOutputConfiguration:" + resource_scene_unique_id

func get_child_resources() -> Array[CPMB_Base]:
	return source_color_ramp_configuration.get_child_resources()

func on_mapped(resource_map : Dictionary[String, Array]) -> void:
	source_color_ramp_configuration.on_mapped(resource_map)

func get_node_name() -> String:
	return "convert/ColorRampNode"

func get_input_port_resources() -> Dictionary[CPMB_Base, int]:
	return source_color_ramp_configuration.get_input_port_resources()

func get_output_port_for_state() -> int:
	return output_channel

func get_source_resource() -> CPMB_Base:
	return source_color_ramp_configuration
