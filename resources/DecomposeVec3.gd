@tool
extends CPMB_FloatValue
class_name CPMB_DecomposeVec3

@export var source_vector : CPMB_Vector3Value
@export_enum("X", "Y", "Z", "Length") var output_channel : int = 0

func _init() -> void:
	source_vector = CPMB_Vector3Value.new()

func get_expression() -> String:
	return "decompose_vector3(%s, %s)" % [index, source_vector.get_expression()]

func get_output_port_for_state() -> int:
	return output_channel
