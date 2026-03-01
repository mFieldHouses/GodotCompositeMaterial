@tool
extends CPMB_FloatValue
class_name CPMB_DecomposeVec4

@export var source_vector : CPMB_Vector4Value
@export_enum("X", "Y", "Z", "W", "Length") var output_channel : int = 0

func _init() -> void:
	source_vector = CPMB_Vector4Value.new()

func get_expression() -> String:
	return "decompose_vector4(%s, %s)" % [index, source_vector.get_expression()]

func get_output_port_for_state() -> int:
	return output_channel
