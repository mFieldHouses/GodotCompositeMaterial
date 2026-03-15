@tool
extends CPMB_NumericValue
class_name CPMB_FloatValue

@export var value : float = 0.0:
	set(x):
		#print("setter on ", resource_scene_unique_id, " for value")
		value = x
		#print("my index is ", index)
		if value != INF:
			value_changed.emit(x, "float_values")

func _init(value : float = 0.0) -> void:
	self.value = value

func get_expression() -> String:
	return "float_values[%s]" % index

func _to_string() -> String:
	return "FloatValue:" + resource_scene_unique_id

func get_mapping_key() -> String:
	return "FloatValue"

func get_node_name() -> String:
	if is_variable:
		return "ValueNode"
	
	return "whoops (FloatValue.gd)"
