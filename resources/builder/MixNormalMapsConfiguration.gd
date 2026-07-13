@tool
extends CPMB_Vector3Value
class_name CPMB_MixNormalMapsConfiguration

@export var normal_map_A : CPMB_Vector3Value
@export var normal_map_B : CPMB_Vector3Value
@export var factor : CPMB_FloatValue

func _init() -> void:
	initialise_value()
	
func initialise_value(index : int = -1) -> void:
	if index == 0 or index == -1:
		normal_map_A = CPMB_Vector3Value.new(Vector3(0.0, 0.0, 1.0))
	
	if index == 1 or index == -1:
		normal_map_B = CPMB_Vector3Value.new(Vector3(0.0, 0.0, 1.0))
	
	if index == 2 or index == -1:
		factor = CPMB_FloatValue.new(0.5)
		factor.internal_to_node = true

func get_expression() -> String:
	return "mix_normals_udn(%s, %s, %s)" % [normal_map_A.get_expression(), normal_map_B.get_expression(), factor.get_expression()]

func get_mapping_key() -> String:
	return "MixNormalMapsConfiguration"

func _to_string() -> String:
	return "MixNormalMapsConfiguration:" + resource_scene_unique_id

func get_child_resources() -> Array[CPMB_Base]:
	return [normal_map_A, normal_map_B, factor]

func get_node_name() -> String:
	return "textures/MixNormalMapsNode"

func get_input_port_resources() -> Dictionary[CPMB_Base, int]:
	return {
		normal_map_A: 0,
		normal_map_B: 1,
		factor: 2
	}
