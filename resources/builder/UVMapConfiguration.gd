@tool
extends CPMB_UVConfiguration
class_name CPMB_UVMapConfiguration

@export var source : int = 0

func get_expression() -> String:
	return "float(uv_map_sources[%s] == 0) * uv + float(uv_map_sources[%s] == 1) * uv2" % [index, index]

func _to_string() -> String:
	return "UVMapConfiguration:" + resource_scene_unique_id

func get_mapping_key() -> String:
	return "UVMapConfiguration"

func get_node_name() -> String:
	return "UVMapNode"
