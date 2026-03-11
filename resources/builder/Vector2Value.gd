@tool
extends CPMB_NumericValue
class_name CPMB_Vector2Value

@export var value : Vector2 = Vector2.ZERO:
	set(x):
		value = x
		
		if x != Vector2.INF:
			print("called from class extending vector2value: ", self)
			value_changed.emit(x, "vector2_values")

func _init(value : Vector2 = Vector2.ZERO) -> void:
	self.value = value

func get_expression() -> String:
	return "vector2_values[%s]" % index

func _to_string() -> String:
	return "Vector2Value:" + resource_scene_unique_id

func get_mapping_key() -> String:
	return "Vector2Value"
