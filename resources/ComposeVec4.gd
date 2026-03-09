@tool
extends CPMB_Vector4Value
class_name CPMB_ComposeVec4

@export var x : CPMB_NumericValue
@export var y : CPMB_NumericValue
@export var z : CPMB_NumericValue
@export var w : CPMB_NumericValue

func _init() -> void:
	initialise_value()

func initialise_value(index : int = -1) -> void:
	if index == 0 or index == -1:
		x = CPMB_FloatValue.new()
	if index == 1 or index == -1:
		y = CPMB_FloatValue.new()
	if index == 2 or index == -1:
		z = CPMB_FloatValue.new()
	if index == 3 or index == -1:
		w = CPMB_FloatValue.new()

func get_value() -> Vector4:
	return Vector4(x.value, y.value, z.value, w.value)

func get_expression() -> String:
	return "vec4(%s, %s, %s, %s)" % [x.get_expression(), y.get_expression(), z.get_expression(), w.get_expression()]

func _to_string() -> String:
	return "ComposeVector4:" + resource_scene_unique_id
