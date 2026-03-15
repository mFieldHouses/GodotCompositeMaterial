@tool
extends CPMB_Vector3Value
class_name CPMB_ComposeVec3

@export var x : CPMB_NumericValue
@export var y : CPMB_NumericValue
@export var z : CPMB_NumericValue

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

func get_expression() -> String:
	return "vec3(%s, %s, %s)" % [x.get_expression(), y.get_expression(), z.get_expression()]

func _to_string() -> String:
	return "ComposeVector3:" + resource_scene_unique_id

func get_mapping_key() -> String:
	return "ComposeVector3"

func get_child_resources() -> Array[CPMB_Base]:
	return [x,y,z]

func get_node_name() -> String:
	if is_variable:
		return "ValueNode"
	
	return "utility/VectorOperationNode"

func get_input_port_resources() -> Dictionary[CPMB_Base, int]:
	return {
		x: 0,
		y: 1,
		z: 2
	}
