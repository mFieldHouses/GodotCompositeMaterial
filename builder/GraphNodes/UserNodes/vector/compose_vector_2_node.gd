@tool
extends CompositeMaterialBuilderGraphNode

var represented_value : CPMB_ComposeVec2

func _node_ready() -> void:
	represented_value = CPMB_ComposeVec2.new()

func get_represented_object(port_idx : int) -> Object:
	return represented_value

func set_represented_object(object : Object) -> void:
	represented_value = object

func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	match input_port_id:
		0:
			represented_value.x = object
		1:
			represented_value.y = object
