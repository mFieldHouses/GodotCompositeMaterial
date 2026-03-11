@tool
extends CPMB_FloatValue
class_name CPMB_DecomposeVec4

@export var source_vector : CPMB_Vector4Value
@export_enum("X", "Y", "Z", "W") var output_channel : int = 0:
	set(x):
		output_channel = x
		value_changed.emit(x, "vector4_decomposition_output_channels")

func _init() -> void:
	initialise_value()

func initialise_value(index : int = -1) -> void:
	source_vector = CPMB_Vector4Value.new()

func get_expression() -> String:
	return "decompose_vector4(%s, %s)" % [index, source_vector.get_expression()]

func get_output_port_for_state() -> int:
	return output_channel

func _to_string() -> String:
	return "DecomposeVector4:" + resource_scene_unique_id

func get_mapping_key() -> String:
	return "DecomposeVector4"

func get_child_resources() -> Array[CPMB_Base]:
	return [source_vector]

func get_node_name() -> String:
	return "utility/VectorOperationNode"
