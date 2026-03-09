@tool
extends CPMB_Vector2Value
class_name CPMB_UVConfiguration

func _init() -> void:
	value = Vector2.INF

func _to_string() -> String:
	return "UVConfiguration:" + resource_scene_unique_id
