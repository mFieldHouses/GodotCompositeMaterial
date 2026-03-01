@tool
extends CPMB_NumericValue
class_name CPMB_Vector4Value

@export var value : Vector4 = Vector4.ZERO:
	set(x):
		value = x
		if x != Vector4.INF:
			value_changed.emit(x, "vector4_values")

func _init(value : Vector4 = Vector4.ZERO) -> void:
	self.value = value

func get_expression() -> String:
	return "vector4_values[%s]" % index
