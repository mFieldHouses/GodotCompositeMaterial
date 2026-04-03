@tool
extends CompositeMaterialBuilderGraphNode
class_name TriplanarMapNode

var represented_configuration : CPMB_TriplanarUVConfiguration

func _node_ready() -> void:
	represented_configuration = CPMB_TriplanarUVConfiguration.new()
	$mode.item_selected.connect(func(x): represented_configuration.space = x)
	$blend.value_changed.connect(func(x): represented_configuration.blend = x)

func get_represented_object(port_idx : int) -> Object:
	return represented_configuration

func set_represented_object(object : Object) -> void:
	represented_configuration = object
	
	$mode.selected = object.space
	$blend.value = object.blend
