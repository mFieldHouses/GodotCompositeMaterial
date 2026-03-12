@tool
extends CPMB_Vector4Value
class_name CPMB_ComposeVec4

@export var x : CPMB_NumericValue
@export var y : CPMB_NumericValue
@export var z : CPMB_NumericValue
@export var w : CPMB_NumericValue

@export var source_identifier : int

func _init() -> void:
	initialise_value()

func initialise_value(index : int = -1) -> void:
	if index == 0 or index == -1:
		x = CPMB_FloatValue.new()
		x.internal_to_node = true
	if index == 1 or index == -1:
		y = CPMB_FloatValue.new()
		y.internal_to_node = true
	if index == 2 or index == -1:
		z = CPMB_FloatValue.new()
		z.internal_to_node = true
	if index == 3 or index == -1:
		w = CPMB_FloatValue.new()
		w.internal_to_node = true

func get_value() -> Vector4:
	return Vector4(x.value, y.value, z.value, w.value)

func get_expression() -> String:
	return "vec4(%s, %s, %s, %s)" % [x.get_expression(), y.get_expression(), z.get_expression(), w.get_expression()]

func _to_string() -> String:
	return "ComposeVector4:" + resource_scene_unique_id

func get_mapping_key() -> String:
	return "ComposeVector4"

func get_child_resources() -> Array[CPMB_Base]:
	return [x,y,z,w]

func get_node_name() -> String:
	return "utility/VectorOperationNode"

func get_input_port_resources() -> Dictionary[CPMB_Base, int]:
	return {
		x: 0,
		y: 1,
		z: 2,
		w: 3
	}
