extends CPMB_Vector4Value
class_name CPMB_ComposeVec4

@export var x : CPMB_NumericValue
@export var y : CPMB_NumericValue
@export var z : CPMB_NumericValue
@export var w : CPMB_NumericValue

func get_value() -> Vector4:
	return Vector4(x.value, y.value, z.value, w.value)
