@tool
extends CPMB_Vector3Value
class_name CPMB_ComposeVec3

@export var x : CPMB_NumericValue
@export var y : CPMB_NumericValue
@export var z : CPMB_NumericValue

func _init() -> void:
	initialise_value()

func initialise_value(index : int = -1) -> void:
	if index == 0 or index == -1:
		x = CPMB_FloatValue.new()
	if index == 1 or index == -1:
		y = CPMB_FloatValue.new()
	if index == 2 or index == -1:
		z = CPMB_FloatValue.new()

func get_value() -> Vector3:
	return Vector3(x.value, y.value, z.value)

func get_expression() -> String:
	return "vec3(%s, %s, %s)" % [x.get_expression(), y.get_expression(), z.get_expression()]

func _to_string() -> String:
	return "ComposeVector3:" + resource_scene_unique_id

func get_mapping_key() -> String:
	return "ComposeVector3"

func get_child_resources() -> Array[CPMB_Base]:
	return [x,y,z]

func get_node_name() -> String:
	return "utility/VectorOperationNode"
