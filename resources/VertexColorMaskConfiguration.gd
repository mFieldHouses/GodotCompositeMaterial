extends CPMB_MaskConfiguration
class_name CPMB_VertexColorMaskConfiguration

enum ColorType {RED, GREEN, BLUE, CUSTOM}
@export var color : ColorType = ColorType.RED
@export_color_no_alpha var custom_color : Color
@export var custom_color_margin : float = 0.005

func get_expression() -> String:
	return "get_vertex_color_mask(%s, VERTEX.rgb)"
