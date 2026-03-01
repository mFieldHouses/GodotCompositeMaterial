extends CPMB_NumericValue
class_name CPMB_Vector3Value

@export var value : Vector3 = Vector3.ZERO

func _init(value : Vector3 = Vector3.ZERO) -> void:
	self.value = value

func get_expression() -> String:
	return "vector3_values[%s]" % index
