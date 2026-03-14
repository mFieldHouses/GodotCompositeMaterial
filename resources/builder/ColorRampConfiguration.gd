@tool
extends CPMB_Vector4Value
class_name CPMB_ColorRampConfiguration

@export var fac : CPMB_NumericValue
@export var gradient_texture : GradientTexture1D:
	set(x):
		gradient_texture = x
		value_changed.emit(x, "color_ramp_textures")
#@export_enum("") var output_channel

func _init() -> void:
	self.value = Vector4.INF
	
	gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = Gradient.new()
	initialise_value()

func initialise_value(index : int = -1) -> void:
	fac = CPMB_FloatValue.new(0.5)
	fac.internal_to_node = true

func get_expression() -> String:
	return "get_color_ramp(%s, %s)" % [index, fac.get_expression()]

func get_mapping_key() -> String:
	return "ColorRampConfiguration"

func _to_string() -> String:
	return "ColorRampConfiguration:" + resource_scene_unique_id

func get_child_resources() -> Array[CPMB_Base]:
	print("get child resources of color ramp")
	return [fac]

func on_mapped(resource_map : Dictionary[String, Array]) -> void:
	if !resource_map.has("ColorRampTexture"):
		resource_map["ColorRampTexture"] = []
	
	resource_map.ColorRampTexture.append(gradient_texture)

func get_node_name() -> String:
	return "textures/ColorRampNode"

func get_input_port_resources() -> Dictionary[CPMB_Base, int]:
	return {
		fac: 0
	}
