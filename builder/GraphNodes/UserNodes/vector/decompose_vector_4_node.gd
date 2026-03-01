@tool
extends CompositeMaterialBuilderGraphNode

var represented_config : CPMB_DecomposeVec4

func _node_ready() -> void:
	represented_config = CPMB_DecomposeVec4.new()

func get_represented_object(port_idx : int) -> Object:
	var result : CPMB_DecomposeVec4 = represented_config.duplicate()
	result.output_channel = port_idx
	
	return result

func set_represented_object(object : Object) -> void:
	represented_config = object

func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	represented_config.source_vector = object
