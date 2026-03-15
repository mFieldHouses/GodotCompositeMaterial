@tool
extends CPMB_NumericValue
class_name CPMB_Vector3Value

@export var as_color : bool = false

@export var value : Vector3 = Vector3.ZERO:
	set(x):
		#print('setting vec3 value to ', x)
		value = x
		
		if x != Vector3.INF:
			#print("calling setter on object ", self, " with value ", x)
			value_changed.emit(x, "vector3_values")

func _init(value : Vector3 = Vector3.ZERO) -> void:
	self.value = value

func get_expression() -> String:
	return "vector3_values[%s]" % index

func _to_string() -> String:
	return "Vector3Value:" + resource_scene_unique_id

func get_mapping_key() -> String:
	return "Vector3Value"

func get_node_name() -> String:
	if is_variable:
		return "ValueNode"
	
	return "whoops (Vector3Value.gd)"
