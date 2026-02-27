@tool
extends CompositeMaterialBuilderGraphNode

var represented_value : CPMB_ComposeVec3 = CPMB_ComposeVec3.new()

func get_represented_object(port_idx : int) -> Object:
	return represented_value

func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	match input_port_id:
		0:
			represented_value.x = object
		1:
			represented_value.y = object
		2:
			represented_value.z = object
