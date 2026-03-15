@tool
extends CompositeMaterialBuilderGraphNode

@export var represented_config : CPMB_HSVTransformConfiguration

func _node_ready() -> void:
	represented_config = CPMB_HSVTransformConfiguration.new()
	
	$h/value.value_changed.connect(func(x): represented_config.h = x)
	$s/value.value_changed.connect(func(x): represented_config.s = x)
	$v/value.value_changed.connect(func(x): represented_config.v = x)

func get_represented_object(port_idx : int) -> Object:
	return represented_config

func set_represented_object(object : Object) -> void:
	represented_config = object

func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	represented_config.input_rgb = object
