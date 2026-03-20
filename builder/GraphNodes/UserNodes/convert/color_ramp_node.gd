@tool
extends CompositeMaterialBuilderGraphNode

@onready var represented_configuration : CPMB_ColorRampConfiguration

func _node_ready() -> void:
	represented_configuration = CPMB_ColorRampConfiguration.new()
	
	$color_ramp_preview.texture = represented_configuration.gradient_texture
	$is_variable.toggled.connect(func(x): represented_configuration.is_variable = x)
	
	if Engine.is_editor_hint():
		node_selected.connect(edit_gradient)

func edit_gradient() -> void:
	EditorInterface.edit_resource(represented_configuration.gradient_texture)

func get_represented_object(port_idx : int) -> Object:
	var _output_config := CPMB_ColorRampOutputConfiguration.new()
	_output_config.source_color_ramp_configuration = represented_configuration
	_output_config.output_channel = port_idx
	
	return _output_config

func set_represented_object(object : Object) -> void:
	represented_configuration = object.source_color_ramp_configuration
	$color_ramp_preview.texture = represented_configuration.gradient_texture

func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	represented_configuration.fac = object
