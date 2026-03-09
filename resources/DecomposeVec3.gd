@tool
extends CPMB_FloatValue
class_name CPMB_DecomposeVec3

@export var source_vector : CPMB_Vector3Value
@export_enum("X", "Y", "Z") var output_channel : int = 0:
	set(x):
		output_channel = x
		value_changed.emit(x, "vector3_decomposition_output_channels")

func _init() -> void:
	source_vector = CPMB_Vector3Value.new()

func get_expression() -> String:
	return "decompose_vector3(%s, %s)" % [index, source_vector.get_expression()]

func get_output_port_for_state() -> int:
	return output_channel

func _to_string() -> String:
	return "DecomposeVector3:" + resource_scene_unique_id
