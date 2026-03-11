@tool
extends CPMB_Vector4Value
class_name CPMB_TextureConfiguration

@export var uv : CPMB_Vector2Value
@export var texture : Texture2D:
	set(x):
		texture = x
		value_changed.emit(x, "textures")

func _init() -> void:
	initialise_value()
	
	value = Vector4.INF

func initialise_value(index : int = -1) -> void:
	uv = CPMB_UVMapConfiguration.new()

func get_expression() -> String:
	return "texture(textures[%s], %s)" % [index, uv.get_expression()]

func _to_string() -> String:
	return "TextureConfiguration:" + resource_scene_unique_id

func get_mapping_key() -> String:
	return "TextureConfiguration"

func get_child_resources() -> Array[CPMB_Base]:
	return [uv]

func on_mapped(resource_map : Dictionary[String, Array]) -> void:
	if !resource_map.has("Texture"):
		resource_map["Texture"] = []
	
	resource_map.Texture.append(texture)

func get_node_name() -> String:
	return "textures/TextureNode"

func get_input_port_resources() -> Dictionary[CPMB_Base, int]:
	return {
		uv: 0
	}
