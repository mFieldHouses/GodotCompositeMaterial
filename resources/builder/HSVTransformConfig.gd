@tool
extends CPMB_Vector3Value
class_name CPMB_HSVTransformConfiguration

@export var input_rgb : CPMB_Vector3Value

@export var h : float = 0.0:
	set(x):
		h = x
		print("h got set")
		value_changed.emit(Vector3(h,s,v), "hsv_transforms")
		
@export var s : float = 0.0:
	set(x):
		s = x
		value_changed.emit(Vector3(h,s,v), "hsv_transforms")
		
@export var v : float = 0.0:
	set(x):
		v = x
		value_changed.emit(Vector3(h,s,v), "hsv_transforms")

func _init() -> void:
	value = Vector3.INF
	
	initialise_value()

func initialise_value(index : int = -1) -> void:
	input_rgb = CPMB_Vector3Value.new()
	input_rgb.internal_to_node = true
	
func _to_string() -> String:
	return "HSVTransformConfiguration:" + resource_scene_unique_id

func get_expression() -> String:
	return "tune_hsv(%s, %s)" % [index, input_rgb.get_expression()]

func get_mapping_key() -> String:
	return "HSVTransformConfiguration"

func get_child_resources() -> Array[CPMB_Base]:
	return [input_rgb]

func get_node_name() -> String:
	return "convert/HSVTransformNode"

func get_input_port_resources() -> Dictionary[CPMB_Base, int]:
	return {
		input_rgb: 0
	}
