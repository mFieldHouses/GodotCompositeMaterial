@tool
extends CPMB_UVConfiguration
class_name CPMB_UVTransformConfiguration

@export var base_uv : CPMB_Vector2Value
@export var scale : CPMB_ComposeVec2
@export var offset : CPMB_ComposeVec2

func _init() -> void:
	value = Vector2.INF
	
	scale = CPMB_ComposeVec2.new()
	scale.internal_to_node = true
	offset = CPMB_ComposeVec2.new()
	offset.internal_to_node = true
	
	initialise_value()

func initialise_value(index : int = -1) -> void:
	if index == 0 or index == -1:
		base_uv = CPMB_UVMapConfiguration.new()
		base_uv.internal_to_node = true
	if index == 1 or index == -1:
		scale.x = CPMB_FloatValue.new(1.0)
		scale.x.internal_to_node = true
	if index == 2 or index == -1:
		scale.y = CPMB_FloatValue.new(1.0)
		scale.y.internal_to_node = true
	if index == 3 or index == -1:
		offset.x = CPMB_FloatValue.new()
		offset.x.internal_to_node = true
	if index == 4 or index == -1:
		offset.y = CPMB_FloatValue.new()
		offset.y.internal_to_node = true
	
func _to_string() -> String:
	return "UVTransformConfiguration:" + resource_scene_unique_id

func get_expression() -> String:
	return "((%s) + %s) * %s" % [base_uv.get_expression(), offset.get_expression(), scale.get_expression()]

func get_mapping_key() -> String:
	return "UVTransformConfiguration"

func get_child_resources() -> Array[CPMB_Base]:
	return [base_uv, scale, offset]

func get_node_name() -> String:
	return "UVTransformNode"

func get_input_port_resources() -> Dictionary[CPMB_Base, int]:
	return {
		base_uv: 0,
		scale.x: 1,
		scale.y: 2,
		offset.x: 3,
		offset.y: 4
	}
