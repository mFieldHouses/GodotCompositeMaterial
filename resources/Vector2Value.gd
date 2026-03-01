@tool
extends CPMB_NumericValue
class_name CPMB_Vector2Value

@export var value : Vector2 = Vector2.ZERO:
	set(x):
		value = x
		
		if x != Vector2.INF:
			value_changed.emit(x, "vector2_values")

func _init(value : Vector2 = Vector2.ZERO) -> void:
	self.value = value

func get_expression() -> String:
	return "vector2_values[%s]" % index
