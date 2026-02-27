@tool
extends CompositeMaterialBuilderGraphNode

var represented_config : CPMB_DecomposeVec3 = CPMB_DecomposeVec3.new()

func get_represented_object(port_idx : int) -> Object:
	var result : CPMB_DecomposeVec3 = represented_config.duplicate()
	result.output_channel = port_idx
	
	return result

func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	represented_config.source_vector = object
