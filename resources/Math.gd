extends CPMB_NumericValue
class_name CPMB_Math

@export var value_A : CPMB_NumericValue
@export_enum("Add", "Subtract", "Multiply", "Divide") var operation : int = 0
@export var value_B : CPMB_NumericValue

func get_value() -> float:
	match operation:
		0:
			return value_A.value + value_B.value
		1:
			return value_A.value - value_B.value
		2:
			return value_A.value * value_B.value
		3:
			return value_A.value / value_B.value
	
	return 0.0
