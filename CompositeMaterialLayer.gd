@tool
extends Resource
class_name CompositeMaterialLayer

@export var albedo : CPMB_Vector4Value = CPMB_Vector4Value.new()
@export var normal : CPMB_Vector3Value = CPMB_Vector3Value.new(Vector3.UP)
@export var roughness_value : CPMB_NumericValue = CPMB_FloatValue.new()
@export var metallic_value : CPMB_NumericValue = CPMB_FloatValue.new()
@export var mask : CPMB_FloatValue = CPMB_FloatValue.new(1.0)
@export var distance_fade_ni : String = "not implemented yet"
