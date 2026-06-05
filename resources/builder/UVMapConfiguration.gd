@tool
extends CPMB_UVConfiguration
class_name CPMB_UVMapConfiguration

@export var source : int = 0:
	set(x):
		source = x
		if source != INF:
			value_changed.emit(x, "uv_map_sources")

func _init() -> void:
	self.value = Vector2.INF

func get_expression() -> String:
	return "get_uv_map(%s, create_uv_map(uv), create_uv_map(uv2))" % index

func _to_string() -> String:
	return "UVMapConfiguration:" + resource_scene_unique_id

func get_mapping_key() -> String:
	return "UVMapConfiguration"

func get_node_name() -> String:
	return "uv/UVMapNode"
