@tool
extends CPMB_NumericValue
class_name CPMB_BoolValue

@export var value : bool = false:
	set(x):
		value = x
		value_changed.emit(x, "bool_values")

func _init(value : bool = false) -> void:
	self.value = value

func get_expression() -> String:
	return "bool_values[%s]" % index

func _to_string() -> String:
	return "BoolValue:" + resource_scene_unique_id

func get_mapping_key() -> String:
	return "BoolValue"
