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
	print("initialise")
	fac = CPMB_FloatValue.new(0.5)

func get_expression() -> String:
	print("expression requested from color ramp")
	return "get_color_ramp(%s, %s)" % [index, fac.get_expression()]
