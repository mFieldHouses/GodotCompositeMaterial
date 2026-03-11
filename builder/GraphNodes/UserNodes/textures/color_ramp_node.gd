@tool
extends CompositeMaterialBuilderGraphNode

@onready var represented_configuration : CPMB_ColorRampConfiguration

func _node_ready() -> void:
	represented_configuration = CPMB_ColorRampConfiguration.new()
	
	$color_ramp_preview.texture = represented_configuration.gradient_texture
	
	if Engine.is_editor_hint():
		node_selected.connect(edit_gradient)

func edit_gradient() -> void:
	EditorInterface.edit_resource(represented_configuration.gradient_texture)

func get_represented_object(port_idx : int) -> Object:
	return represented_configuration

func set_represented_object(object : Object) -> void:
	represented_configuration = object
	$color_ramp_preview.texture = represented_configuration.gradient_texture

func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	represented_configuration.fac = object
