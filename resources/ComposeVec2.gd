@tool
extends CPMB_Vector2Value
class_name CPMB_ComposeVec2

@export var x : CPMB_NumericValue = CPMB_FloatValue.new()
@export var y : CPMB_NumericValue = CPMB_FloatValue.new()

func _init() -> void:
	value = Vector2.INF
	initialise_value()

func initialise_value(index : int = -1) -> void:
	if index == 0 or index == -1:
		x = CPMB_FloatValue.new()
	if index == 1 or index == -1:
		y = CPMB_FloatValue.new()


func get_value() -> Vector2:
	return Vector2(x.value, y.value)

func get_expression() -> String:
	return "vec2(%s, %s)" % [x.get_expression(), y.get_expression()]

func _to_string() -> String:
	return "ComposeVector2:" + resource_scene_unique_id
