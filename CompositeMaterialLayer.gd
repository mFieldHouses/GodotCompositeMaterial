@tool
extends Resource
class_name CompositeMaterialLayer

@export var albedo : CPMB_Vector4Value
@export var normal : CPMB_Vector3Value
@export var roughness_value : CPMB_NumericValue = CPMB_FloatValue.new()
@export var metallic_value : CPMB_NumericValue = CPMB_FloatValue.new()
@export var mask : CPMB_FloatValue
@export var distance_fade_ni : String = "not implemented yet"
