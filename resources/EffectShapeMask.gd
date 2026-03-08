@tool
extends CPMB_MaskConfiguration
class_name CPMB_EffectShapeMaskConfiguration

@export var layer : int = 0:
	set(x):
		layer = x
		value_changed.emit(x, "effect_shape_mask_layers")
@export var falloff_distance : float = 1.0:
	set(x):
		falloff_distance = x
		value_changed.emit(x, "effect_shape_mask_falloff_distances")

func get_expression() -> String:
	return "get_effect_shape_mask(%s, global_vertex_pos)" % index

func _to_string() -> String:
	return "EffectShapeMask:" + resource_scene_unique_id

func call_setters() -> void:
	layer = layer
	falloff_distance = falloff_distance
