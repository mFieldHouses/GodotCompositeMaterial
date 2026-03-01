@tool
extends CPMB_UVConfiguration
class_name CPMB_UVTransformConfiguration

@export var base_uv : CPMB_Vector2Value
@export var scale : CPMB_ComposeVec2
@export var offset : CPMB_ComposeVec2

func _init() -> void:
	base_uv = CPMB_UVMapConfiguration.new()
	scale = CPMB_ComposeVec2.new()
	scale.x.value = 1.0
	scale.y.value = 1.0
	
	offset = CPMB_ComposeVec2.new()

func get_expression() -> String:
	return "((%s) + uv_transform_offsets[%s]) * uv_transform_scales[%s]" % [base_uv.get_expression(), index, index]
