@tool
extends CPMB_MaskConfiguration
class_name CPMB_EffectShapeMaskConfiguration

@export var layer : int = 0
@export var max_distance : float = 1.0

func get_expression() -> String:
	return "get_effect_shape_mask(%s)" % index
