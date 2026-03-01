extends CPMB_NumericValue
class_name CPMB_IntValue

@export var value : int = 0

func _init(value : int = 0) -> void:
	self.value = value

func get_expression() -> String:
	return "int_values[%s]" % index
