extends CompositeMaterialBuilderGraphNode

var represented_value : CPMB_ComposeVec4 = CPMB_ComposeVec4.new()

func get_represented_object() -> Object:
	return represented_value

func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	match input_port_id:
		0:
			represented_value.x = object
		1:
			represented_value.y = object
		2:
			represented_value.z = object
		3:
			represented_value.w = object
