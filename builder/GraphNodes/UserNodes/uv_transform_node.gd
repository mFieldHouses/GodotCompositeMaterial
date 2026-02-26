@tool
extends CompositeMaterialBuilderGraphNode

@onready var represented_uv_config : CPMB_UVTransformConfiguration = CPMB_UVTransformConfiguration.new()

func _node_ready() -> void:
	$scale_x/value.changed.connect(func(x): represented_uv_config.scale.x = x)
	$scale_y/value.changed.connect(func(x): represented_uv_config.scale.y = x)
	$offset_x/value.changed.connect(func(x): represented_uv_config.offset.x = x)
	$offset_y/value.changed.connect(func(x): represented_uv_config.offset.y = x)

func get_represented_object() -> Object:
	return represented_uv_config

func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	match input_port_id:
		0:
			represented_uv_config.base_uv = object
		1:
			represented_uv_config.scale_x = object
		2:
			represented_uv_config.scale_y = object
		3:
			represented_uv_config.offset_x = object
		4:
			represented_uv_config.offset_y = object
