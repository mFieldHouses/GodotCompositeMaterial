@tool
extends CPMB_Vector4Value
class_name CPMB_ColorRampConfiguration

@export var fac : CPMB_NumericValue
@export var gradient_texture : GradientTexture1D:
	set(x):
		gradient_texture = x
		value_changed.emit(x, "color_ramp_textures")

func _init() -> void:
	fac = CPMB_FloatValue.new(0.5)
	gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = Gradient.new()

func get_expression() -> String:
	return "get_color_ramp(%s, %s)" % [index, fac.get_expression()]
