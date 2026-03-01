@tool
extends CPMB_NumericValue
class_name CPMB_FloatValue

@export var value : float = 0.0:
	set(x):
		value = x
		value_changed.emit(x, "float_values")

func _init(value : float = 0.0) -> void:
	self.value = value

func get_expression() -> String:
	return "float_values[%s]" % index
