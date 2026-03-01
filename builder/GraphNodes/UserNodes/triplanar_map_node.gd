extends CompositeMaterialBuilderGraphNode
class_name TriplanarMapNode

var represented_configuration : CPMB_TriplanarUVConfiguration

func _node_ready() -> void:
	represented_configuration = CPMB_TriplanarUVConfiguration.new()

func get_represented_object(port_idx : int) -> Object:
	return represented_configuration

func set_represented_object(object : Object) -> void:
	represented_configuration = object
