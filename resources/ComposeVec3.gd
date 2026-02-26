extends CPMB_Vector3Value
class_name CPMB_ComposeVec3

@export var x : CPMB_NumericValue
@export var y : CPMB_NumericValue
@export var z : CPMB_NumericValue

func get_value() -> Vector3:
	return Vector3(x.value, y.value, z.value)
