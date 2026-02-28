extends CPMB_NumericValue
class_name CPMB_Vector4Value

@export var value : Vector4 = Vector4.ZERO

func get_expression() -> String:
	return "vector4_values[%s]" % index
