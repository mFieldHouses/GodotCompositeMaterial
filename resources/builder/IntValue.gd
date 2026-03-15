@tool
extends CPMB_NumericValue
class_name CPMB_IntValue

@export var value : int = 0:
	set(x):
		value = x
		
		if value != INF:
			value_changed.emit(x, "int_values")

func _init(value : int = 0) -> void:
	self.value = value

func get_expression() -> String:
	return "int_values[%s]" % index

func _to_string() -> String:
	return "IntValue:" + resource_scene_unique_id

func get_mapping_key() -> String:
	return "IntValue"

func get_node_name() -> String:
	if is_variable:
		return "ValueNode"
	
	return "whoops (IntValue.gd)"
