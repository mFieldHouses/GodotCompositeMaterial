extends CPMB_NumericValue
class_name CPMB_IntValue

@export var value : int = 0

func get_expression() -> String:
	return "int_values[%s]" % index
