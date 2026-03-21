@tool
extends CPMB_MaskConfiguration
class_name CPMB_VertexColorMaskConfiguration

enum ColorType {RED, GREEN, BLUE, CUSTOM}
@export var color : ColorType = ColorType.RED:
	set(x):
		color = x
		value_changed.emit(x, "vertex_color_mask_modes")
		
@export_color_no_alpha var custom_color : Color
@export var custom_color_margin : float = 0.005

func get_expression() -> String:
	return "get_vertex_color_mask(%s, vertex_color)" % index

func get_mapping_key() -> String:
	return "VertexColorMaskConfiguration"

func get_node_name() -> String:
	return "masks/VertexColorMaskNode"
