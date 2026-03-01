@tool
extends CPMB_NumericValue
class_name CPMB_Vector3Value

@export var value : Vector3 = Vector3.ZERO:
	set(x):
		value = x
		
		if x != Vector3.INF:
			value_changed.emit(x, "vector3_values")

func _init(value : Vector3 = Vector3.ZERO) -> void:
	self.value = value

func get_expression() -> String:
	return "vector3_values[%s]" % index
