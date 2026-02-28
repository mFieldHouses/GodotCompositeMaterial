extends CPMB_NumericValue
class_name CPMB_Vector2Value

@export var value : Vector2 = Vector2.ZERO

func get_expression() -> String:
	return "vector2_values[%s]" % index
