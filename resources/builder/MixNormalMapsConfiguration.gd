@tool
extends CPMB_Vector3Value
class_name CPMB_MixNormalMapsConfiguration

@export var normal_map_A : CPMB_Vector3Value
@export var normal_map_B : CPMB_Vector3Value
@export_range(0.0, 1.0, 0.001) var factor : float = 0.5:
	set(x):
		factor = x
		value_changed.emit(x, "float_values")

func _init() -> void:
	print("init mix normals resource")
	self.factor = 0.5
	initialise_value()
	
func initialise_value(index : int = -1) -> void:
	if index == 0 or index == -1:
		normal_map_A = CPMB_Vector3Value.new(Vector3(0.0, 0.0, 1.0))
	
	if index == 1 or index == -1:
		normal_map_B = CPMB_Vector3Value.new(Vector3(0.0, 0.0, 1.0))

func get_expression() -> String:
	return "mix_normals_udn(%s, %s, %s)" % [normal_map_A.get_expression(), normal_map_B.get_expression(), factor]

func get_mapping_key() -> String:
	return "MixNormalMapsConfiguration"

func _to_string() -> String:
	return "MixNormalMapsConfiguration:" + resource_scene_unique_id

func get_child_resources() -> Array[CPMB_Base]:
	return [normal_map_A, normal_map_B]

func get_node_name() -> String:
	return "textures/MixNormalMapsNode"

func get_input_port_resources() -> Dictionary[CPMB_Base, int]:
	return {
		normal_map_A: 0,
		normal_map_B: 1
	}
