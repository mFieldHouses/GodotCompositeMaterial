@tool
extends CPMB_Vector4Value
class_name CPMB_ColorRampConfiguration

@export var fac : CPMB_NumericValue
@export var gradient_texture : GradientTexture1D:
	set(x):
		gradient_texture = x
		value_changed.emit(x, "color_ramp_textures")
#@export_enum("") var output_channel

@export var texture_index : int = 0

func _init() -> void:
	self.value = Vector4.INF
	
	gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = Gradient.new()
	initialise_value()

func initialise_value(index : int = -1) -> void:
	fac = CPMB_FloatValue.new(0.5)
	fac.internal_to_node = true
#
func get_expression() -> String:
	printerr("get expression from source color ramp")
	return "WRONG EXPRESSION"

#func get_mapping_key() -> String:
	#return "ColorRampConfiguration"

func _to_string() -> String:
	return "ColorRampConfiguration:" + resource_scene_unique_id

func get_child_resources() -> Array[CPMB_Base]:
	return [fac]

func on_mapped(resource_map : Dictionary[String, Array]) -> void:
	if !resource_map.has("ColorRampTexture"):
		resource_map["ColorRampTexture"] = []
	
	var _idx : int = resource_map.ColorRampTexture.find(gradient_texture)
	if _idx == -1:
		resource_map.ColorRampTexture.append(gradient_texture)
		texture_index = resource_map.ColorRampTexture.size() - 1
	else:
		texture_index = _idx

func get_node_name() -> String:
	return "convert/ColorRampNode"

func get_input_port_resources() -> Dictionary[CPMB_Base, int]:
	return {
		fac: 0
	}
