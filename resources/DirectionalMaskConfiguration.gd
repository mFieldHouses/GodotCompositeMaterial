@tool
extends CPMB_MaskConfiguration
class_name CPMB_DirectionalMaskConfiguration

@export var space : int = 0:
	set(x):
		space = x
		value_changed.emit(x, "directional_mask_spaces")
@export var direction : Vector3 = Vector3.UP:
	set(x):
		direction = x
		value_changed.emit(x, "directional_mask_directions")

enum PolarityType {BIPOLAR, MONOPOLAR_POSITIVE, MONOPOLAR_NEGATIVE}
@export var polarity : PolarityType = PolarityType.BIPOLAR:
	set(x):
		polarity = x
		value_changed.emit(x, "directional_mask_polarities")

func get_expression() -> String:
	return "get_directional_mask(%s, local_vertex_normal, global_vertex_normal)" % index
