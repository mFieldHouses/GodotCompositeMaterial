@tool
extends CPMB_Vector3Value
class_name CPMB_NormalMapConfiguration

@export var uv : CPMB_Vector2Value
@export var normal_map : Texture2D:
	set(x):
		normal_map = x
		value_changed.emit(x, "normal_map_textures")
@export_range(0.001, 20.0, 0.001) var scale : float = 1.0:
	set(x):
		scale = x
		value_changed.emit(x, "normal_map_scales")

func _init(value : Vector3 = Vector3.ZERO) -> void:
	self.value = Vector3.INF
	initialise_value()
	
func initialise_value(index : int = -1) -> void:
	if index == 0 or index == -1:
		uv = CPMB_UVMapConfiguration.new()
		uv.internal_to_node = true

func get_expression() -> String:
	return "mix(vec3(0.5, 0.5, 1.0), texture(normal_map_textures[%s], %s).rgb, normal_map_scales[%s])" % [index, uv.get_expression(), index]

func get_mapping_key() -> String:
	return "NormalMapConfiguration"

func _to_string() -> String:
	return "NormalMapConfiguration:" + resource_scene_unique_id

func get_child_resources() -> Array[CPMB_Base]:
	return [uv]

func on_mapped(resource_map : Dictionary[String, Array]) -> void:
	if !resource_map.has("NormalMapTexture"):
		resource_map["NormalMapTexture"] = []
	
	resource_map.NormalMapTexture.append(normal_map)

func get_node_name() -> String:
	return "textures/NormalMapNode"

func get_input_port_resources() -> Dictionary[CPMB_Base, int]:
	return {
		uv: 0
	}
