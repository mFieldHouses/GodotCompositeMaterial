@tool
extends CompositeMaterialBuilderGraphNode

var represented_config : CPMB_UVMapConfiguration

func _node_ready() -> void:
	represented_config = CPMB_UVMapConfiguration.new()

func get_represented_object(port_idx : int) -> Object:
	return represented_config

func set_represented_object(object : Object) -> void:
	represented_config = object
