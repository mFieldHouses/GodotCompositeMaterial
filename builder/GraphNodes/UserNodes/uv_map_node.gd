@tool
extends CompositeMaterialBuilderGraphNode

var represented_config : CPMB_UVMapConfiguration = CPMB_UVMapConfiguration.new()

func get_represented_object(port_idx : int) -> Object:
	return represented_config
