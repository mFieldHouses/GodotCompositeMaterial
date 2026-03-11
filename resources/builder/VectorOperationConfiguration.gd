@tool
extends CPMB_NumericValue
class_name CPMB_VectorOperationConfiguration

@export var source_vector : CPMB_NumericValue

@export var x_in : CPMB_NumericValue
@export var y_in : CPMB_NumericValue
@export var z_in : CPMB_NumericValue
@export var w_in : CPMB_NumericValue

enum VectorType {VECTOR2, VECTOR3, VECTOR4}
@export var vector_type : VectorType = VectorType.VECTOR2

enum OperationType {
	COMPOSE, DECOMPOSE,
	ADD, SUBTRACT, MULTIPLY, DIVIDE,
	POWER, ROOT, LOGARITHM, NATURAL_LOGARITHM
}
@export var operation : OperationType = OperationType.ADD

func _init() -> void:
	initialise_value()

func initialise_value(index : int = -1) -> void:
	if index == 0 or index == -1:
		x_in = CPMB_FloatValue.new()
	if index == 1 or index == -1:
		y_in = CPMB_FloatValue.new()
	if index == 2 or index == -1:
		z_in = CPMB_FloatValue.new()
	if index == 3 or index == -1:
		w_in = CPMB_FloatValue.new(1.0)
