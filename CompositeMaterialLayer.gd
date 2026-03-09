@tool
extends Resource
class_name CompositeMaterialLayer

@export var albedo : CPMB_Vector4Value
@export var normal : CPMB_Vector3Value
@export var roughness_value : CPMB_NumericValue
@export var metallic_value : CPMB_NumericValue = CPMB_FloatValue.new()
@export var mask : CPMB_FloatValue
@export var distance_fade_ni : String = "not implemented yet"

func _init() -> void:
	initialise_value()

func initialise_value(index : int = -1) -> void:
	if index == 0 or index == -1:
		albedo = CPMB_Vector4Value.new()
	if index == 1 or index == -1:
		normal = CPMB_Vector3Value.new(Vector3.UP)
	if index == 2 or index == -1:
		roughness_value = CPMB_FloatValue.new()
	if index == 3 or index == -1:
		metallic_value = CPMB_FloatValue.new()
	if index == 4 or index == -1:
		mask = CPMB_FloatValue.new(1.0)
