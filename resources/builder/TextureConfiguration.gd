@tool
extends CPMB_Vector3Value
class_name CPMB_TextureConfiguration

signal texture_changed(new_texture : Texture2D)

@export var uv : CPMB_Vector2Value
@export var texture : Texture2D:
	set(x):
		print("setter on source texture")
		texture = x
		texture_changed.emit(x)
		value_changed.emit(x, "textures")

@export var texture_index : int = 0

func _init() -> void:
	initialise_value()
	self.value = Vector3.INF

func initialise_value(index : int = -1) -> void:
	uv = CPMB_UVMapConfiguration.new()
	uv.internal_to_node = true

#func get_expression() -> String:
	#return "texture(textures[%s], %s)" % [index, uv.get_expression()]

func _to_string() -> String:
	return "TextureConfiguration:" + resource_scene_unique_id

#func get_mapping_key() -> String:
	#return "TextureConfiguration"

func get_child_resources() -> Array[CPMB_Base]:
	return [uv]

func on_mapped(resource_map : Dictionary[String, Array]) -> void:
	if !resource_map.has("Texture"):
		resource_map["Texture"] = []
	
	var _idx : int = resource_map.Texture.find(texture)
	if _idx == -1:
		resource_map.Texture.append(texture)
		texture_index = resource_map.Texture.size() - 1
	else:
		texture_index = _idx

func get_node_name() -> String:
	return "textures/TextureNode"

func get_input_port_resources() -> Dictionary[CPMB_Base, int]:
	return {
		uv: 0
	}
