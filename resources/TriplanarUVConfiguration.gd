@tool
extends CPMB_UVConfiguration
class_name CPMB_TriplanarUVConfiguration

@export_enum("Local", "Global") var space : int = 0:
	set(x):
		space = x
		value_changed.emit(x, "triplanar_map_spaces")

func get_expression() -> String:
	return "get_triplanar_uv(%s, local_vertex_normal, global_vertex_normal, local_vertex_pos, global_vertex_pos)" % index

func _to_string() -> String:
	return "TriplanarUVConfiguration:" + resource_scene_unique_id
