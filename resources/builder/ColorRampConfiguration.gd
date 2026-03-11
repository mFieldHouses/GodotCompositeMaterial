@tool
extends CPMB_Vector4Value
class_name CPMB_ColorRampConfiguration

@export var fac : CPMB_NumericValue
@export var gradient_texture : GradientTexture1D:
	set(x):
		gradient_texture = x
		value_changed.emit(x, "color_ramp_textures")

func _init() -> void:
	gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = Gradient.new()
	initialise_value()

func initialise_value(index : int = -1) -> void:
	fac = CPMB_FloatValue.new(0.5)

func get_expression() -> String:
	return "get_color_ramp(%s, %s)" % [index, fac.get_expression()]

func get_mapping_key() -> String:
	return "CPMB_ColorRampConfiguration"

func get_child_resources() -> Array[CPMB_Base]:
	return [fac]

func on_mapped(resource_map : Dictionary[String, Array]) -> void:
	resource_map.ColorRampTexture.append(gradient_texture)

func get_node_name() -> String:
	return "textures/ColorRampNode"
