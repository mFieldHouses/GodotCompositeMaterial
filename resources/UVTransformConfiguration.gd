extends CPMB_UVConfiguration
class_name CPMB_UVTransformConfiguration

@export var base_uv : CPMB_Vector2Value
@export var scale : CPMB_ComposeVec2
@export var scale_x : CPMB_NumericValue
@export var scale_y : CPMB_NumericValue
@export var offset : CPMB_ComposeVec2
@export var offset_x : CPMB_NumericValue
@export var offset_y : CPMB_NumericValue

func get_expression() -> String:
	return "(" + base_uv.get_expression() + ")"
	
	"((((%s) + uv_transform_offsets[%s]) * uv_transform_scales[%s]" % [base_uv.get_expression(), index, index]
