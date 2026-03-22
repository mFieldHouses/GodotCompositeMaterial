@tool
extends CPMB_UVConfiguration
class_name CPMB_TriplanarUVConfiguration

@export_enum("Local", "Global") var space : int = 0:
	set(x):
		space = x
		value_changed.emit(x, "triplanar_map_spaces")

@export var blend : float = 1.0:
	set(x):
		blend = x
		value_changed.emit(x, "triplanar_map_blends")

func _init() -> void:
	self.value = Vector2.INF

func get_expression() -> String:
	return "get_triplanar_uv(%s)" % index

func _to_string() -> String:
	return "TriplanarUVConfiguration:" + resource_scene_unique_id

func get_mapping_key() -> String:
	return "TriplanarUVConfiguration"

func get_node_name() -> String:
	return "TriplanarMapNode"
