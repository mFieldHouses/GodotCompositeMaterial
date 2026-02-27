extends CompositeMaterialBuilderGraphNode
class_name TriplanarMapNode

var represented_configuration : CPMB_TriplanarUVConfiguration = CPMB_TriplanarUVConfiguration.new()

func get_represented_object(port_idx : int) -> Object:
	return represented_configuration
