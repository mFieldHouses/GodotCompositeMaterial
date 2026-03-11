@tool
extends CPMB_FloatValue
class_name CPMB_DecomposeVec2

@export var source_vector : CPMB_Vector2Value
@export_enum("X", "Y") var output_channel : int = 0:
	set(x):
		output_channel = x
		value_changed.emit(x, "vector2_decomposition_output_channels")

func _init() -> void:
	initialise_value()

func initialise_value(index : int = -1) -> void:
	source_vector = CPMB_Vector2Value.new()

func get_expression() -> String:
	return "decompose_vector2(%s, %s)" % [index, source_vector.get_expression()]

func get_output_port_for_state() -> int:
	return output_channel

func _to_string() -> String:
	return "DecomposeVector2:" + resource_scene_unique_id

func get_mapping_key() -> String:
	return "DecomposeVector2"

func get_child_resources() -> Array[CPMB_Base]:
	return [source_vector]

func get_node_name() -> String:
	return "utility/VectorOperationNode"

func get_input_port_resources() -> Dictionary[CPMB_Base, int]:
	return {
		source_vector: 0
	}
