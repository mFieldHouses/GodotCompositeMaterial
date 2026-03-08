@tool
extends CPMB_NumericValue
class_name CPMB_FloatValue

@export var value : float = 0.0:
	set(x):
		#print("setter on ", resource_scene_unique_id, " for value")
		value = x
		#print("my index is ", index)
		value_changed.emit(x, "float_values")

func _init(value : float = 0.0) -> void:
	self.value = value

func get_expression() -> String:
	return "float_values[%s]" % index

func _to_string() -> String:
	return "FloatValue:" + resource_scene_unique_id

#func call_setters() -> void:
	##print("Unoverridden call_setters on ", self)
	#value = value
