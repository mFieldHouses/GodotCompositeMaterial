@tool
extends CPMB_FloatValue
class_name CPMB_DecomposeVec3

@export var source_vector : CPMB_Vector3Value
@export_enum("X", "Y", "Z") var output_channel : int = 0:
	set(x):
		output_channel = x
		value_changed.emit(x, "vector3_decomposition_output_channels")

@export var source_identifier : int

func _init() -> void:
	initialise_value()

func initialise_value(index : int = -1) -> void:
	source_vector = CPMB_Vector3Value.new()
	source_vector.internal_to_node = true

func get_expression() -> String:
	return "decompose_vector3(%s, %s)" % [index, source_vector.get_expression()]

func get_output_port_for_state() -> int:
	return output_channel

func _to_string() -> String:
	return "DecomposeVector3:" + resource_scene_unique_id

func get_mapping_key() -> String:
	return "DecomposeVector3"

func get_child_resources() -> Array[CPMB_Base]:
	return [source_vector]

func get_node_name() -> String:
	return "utility/VectorOperationNode"

func get_input_port_resources() -> Dictionary[CPMB_Base, int]:
	return {
		source_vector: 0
	}
