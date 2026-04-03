@tool
extends CompositeMaterialBuilderGraphNode

@onready var represented_uv_config : CPMB_UVTransformConfiguration

func _node_ready() -> void:
	represented_uv_config = CPMB_UVTransformConfiguration.new()
	
	$scale_x/value.value_changed.connect(func(x): represented_uv_config.scale.x.value = x)
	$scale_y/value.value_changed.connect(func(x): represented_uv_config.scale.y.value = x)
	$offset_x/value.value_changed.connect(func(x): represented_uv_config.offset.x.value = x)
	$offset_y/value.value_changed.connect(func(x): represented_uv_config.offset.y.value = x)

func get_represented_object(port_idx : int) -> Object:
	return represented_uv_config

func set_represented_object(object : Object) -> void:
	represented_uv_config = object
	
	$scale_x/value.value = object.scale.x.value
	$scale_y/value.value = object.scale.y.value
	$offset_x/value.value = object.offset.x.value
	$offset_y/value.value = object.offset.y.value
	
func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	#print("passing object to ", self, ", port ", input_port_id, ": ", object)
	match input_port_id:
		0:
			represented_uv_config.base_uv = object
		1:
			represented_uv_config.scale.x = object
		2:
			represented_uv_config.scale.y = object
		3:
			represented_uv_config.offset.x = object
		4:
			represented_uv_config.offset.y = object
