@tool
extends CompositeMaterialBuilderGraphNode
class_name MaskTextureNode

@export var respresented_texture_config : CPMB_MaskTextureConfiguration

func _node_ready() -> void:
	respresented_texture_config = CPMB_MaskTextureConfiguration.new()
	
	if Engine.is_editor_hint():
		node_selected.connect(edit_texture)
		respresented_texture_config.texture_changed.connect(update_preview)

func edit_texture() -> void:
	EditorInterface.edit_resource(respresented_texture_config)

func get_represented_object(port_idx : int) -> Object:
	return respresented_texture_config

func set_represented_object(object : Object) -> void:
	respresented_texture_config = object
	update_preview()

func update_preview() -> void:
	$texture_view.texture = respresented_texture_config.texture

func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	match input_port_id:
		0:
			respresented_texture_config.uv = object

func disconnected(input_port_id : int) -> void:
	respresented_texture_config.initialise_value(input_port_id)
