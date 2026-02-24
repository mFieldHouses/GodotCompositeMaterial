@tool
extends CompositeMaterialBuilderGraphNode

@onready var represented_uv_config : UVTransformConfiguration = UVTransformConfiguration.new()

func _node_ready() -> void:
	$scale_x/value.changed.connect(func(x): represented_uv_config.scale.x = x)
	$scale_y/value.changed.connect(func(x): represented_uv_config.scale.y = x)
	$offset_x/value.changed.connect(func(x): represented_uv_config.offset.x = x)
	$offset_y/value.changed.connect(func(x): represented_uv_config.offset.y = x)
