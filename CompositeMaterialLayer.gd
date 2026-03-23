@tool
extends Resource
class_name CompositeMaterialLayer

@export var albedo : CPMB_Vector3Value
@export var alpha : CPMB_NumericValue:
	set(x):
		alpha = x
		#print("setter on ", self, " alpha: set to ", x)
@export var normal : CPMB_Vector3Value
@export var roughness_value : CPMB_NumericValue
@export var metallic_value : CPMB_NumericValue = CPMB_FloatValue.new()
@export var mask : CPMB_NumericValue
@export var distance_fade_ni : String = "not implemented yet"

@export var node_position : Vector2 = Vector2.ZERO

var is_descendant_resource : bool = false #for parity, has no further function

func _init() -> void:
	initialise_value()

func initialise_value(index : int = -1) -> void:
	if index == 0 or index == -1:
		albedo = CPMB_Vector3Value.new(Vector3(1.0, 0.0, 1.0))
		albedo.internal_to_node = true
	if index == 1 or index == -1:
		alpha = CPMB_FloatValue.new(1.0)
		alpha.internal_to_node = true
	if index == 2 or index == -1:
		normal = CPMB_Vector3Value.new(Vector3(0.5, 0.5, 1.0))
		normal.internal_to_node = true
	if index == 3 or index == -1:
		roughness_value = CPMB_FloatValue.new()
		roughness_value.internal_to_node = true
	if index == 4 or index == -1:
		metallic_value = CPMB_FloatValue.new()
		metallic_value.internal_to_node = true
	if index == 5 or index == -1:
		mask = CPMB_FloatValue.new(0.5)
		mask.internal_to_node = true

func get_child_resources() -> Array[CPMB_Base]:
	return [albedo, alpha, normal, roughness_value, metallic_value, mask]

func get_input_port_resources() -> Dictionary[CPMB_Base, int]:
	return {
		albedo: 0,
		alpha: 1,
		normal: 2,
		roughness_value: 3,
		metallic_value: 4,
		mask: 5
	}
