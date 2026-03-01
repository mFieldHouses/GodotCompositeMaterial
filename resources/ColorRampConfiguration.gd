@tool
extends CPMB_MaskConfiguration
class_name CPMB_ColorRampConfiguration

@export var fac : CPMB_NumericValue
@export var gradient : GradientTexture1D

func _init() -> void:
	fac = CPMB_FloatValue.new(0.5)
	gradient = GradientTexture1D.new()
