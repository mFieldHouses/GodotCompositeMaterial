@tool
extends CPMB_UVConfiguration
class_name CPMB_UVTransformConfiguration

@export var base_uv : CPMB_Vector2Value
@export var scale : CPMB_ComposeVec2
@export var offset : CPMB_ComposeVec2

func _init() -> void:
	value = Vector2.INF
	
	scale = CPMB_ComposeVec2.new()
	offset = CPMB_ComposeVec2.new()
	
	initialise_value()

func initialise_value(index : int = -1) -> void:
	if index == 0 or index == -1:
		base_uv = CPMB_UVMapConfiguration.new()
	if index == 1 or index == -1:
		scale.x = CPMB_FloatValue.new(1.0)
	if index == 2 or index == -1:
		scale.y = CPMB_FloatValue.new(1.0)
	if index == 3 or index == -1:
		offset.x = CPMB_FloatValue.new()
	if index == 4 or index == -1:
		offset.y = CPMB_FloatValue.new()
	
func _to_string() -> String:
	return "UVTransformConfiguration:" + resource_scene_unique_id

func get_expression() -> String:
	return "((%s) + %s) * %s" % [base_uv.get_expression(), offset.get_expression(), scale.get_expression()]
