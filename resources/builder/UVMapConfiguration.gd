@tool
extends CPMB_UVConfiguration
class_name CPMB_UVMapConfiguration

@export var source : int = 0

func _init() -> void:
	self.value = Vector2.INF

func get_expression() -> String:
	return "get_uv_map(%s, create_uv_map(uv), create_uv_map(uv2))" % index

func _to_string() -> String:
	return "UVMapConfiguration:" + resource_scene_unique_id

func get_mapping_key() -> String:
	return "UVMapConfiguration"

func get_node_name() -> String:
	return "UVMapNode"
