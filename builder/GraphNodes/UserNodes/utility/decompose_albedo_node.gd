@tool
extends CompositeMaterialBuilderGraphNode

var represented_config : CPMB_DecomposeVec4 = CPMB_DecomposeVec4.new()

func get_represented_object() -> Object:
	return represented_config

func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	represented_config.source_vector = object
