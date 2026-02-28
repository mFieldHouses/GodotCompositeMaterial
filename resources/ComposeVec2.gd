extends CPMB_Vector2Value
class_name CPMB_ComposeVec2

@export var x : CPMB_NumericValue
@export var y : CPMB_NumericValue

func get_value() -> Vector2:
	return Vector2(x.value, y.value)

func get_expression() -> String:
	return "vec2(%s, %s)" % [x.get_expression(), y.get_expression()]
