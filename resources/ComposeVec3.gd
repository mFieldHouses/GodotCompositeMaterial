@tool
extends CPMB_Vector3Value
class_name CPMB_ComposeVec3

@export var x : CPMB_NumericValue
@export var y : CPMB_NumericValue
@export var z : CPMB_NumericValue

func _init() -> void:
	x = CPMB_FloatValue.new()
	y = CPMB_FloatValue.new()
	z = CPMB_FloatValue.new()

func get_value() -> Vector3:
	return Vector3(x.value, y.value, z.value)

func get_expression() -> String:
	return "vec3(%s, %s, %s)" % [x.get_expression(), y.get_expression(), z.get_expression()]
