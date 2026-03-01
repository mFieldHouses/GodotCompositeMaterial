extends CPMB_NumericValue
class_name CPMB_FloatValue

@export var value : float = 0.0

func _init(value : float = 0.0) -> void:
	self.value = value

func get_expression() -> String:
	return "float_values[%s]" % index
