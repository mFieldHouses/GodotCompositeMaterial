@tool
extends CompositeMaterialBuilderGraphNode

var represented_config : CPMB_TimeConfig

func _ready() -> void:
	represented_config = CPMB_TimeConfig.new()
	$scale.value_changed.connect(func(x): represented_config.scale.value = x)

func get_represented_object(port_idx : int) -> Object:
	return represented_config

func set_represented_object(object : Object) -> void:
	represented_config = object
