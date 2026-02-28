extends CPMB_MaskConfiguration
class_name CPMB_PositionalMaskConfiguration

@export var space : int = 0
@export var axis : Vector3 = Vector3.UP
@export var min : float = -1.0
@export var max : float = 1.0

func get_expression() -> String:
	return "get_positional_mask(%s, local_vertex_pos, global_vertex_pos)" % index
