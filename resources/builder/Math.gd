@tool
extends CPMB_FloatValue
class_name CPMB_Math

enum OperationType {
	ADD, SUBTRACT, MULTIPLY, DIVIDE,
	POWER, ROOT, LOGARITHM, NATURAL_LOGARITHM
}

@export var value_A : CPMB_NumericValue:
	set(x):
		value_A = x
		print("Setter on value_A")

@export var operation : OperationType = 0:
	set(x):
		operation = x
		request_material_rebuild.emit()
		
@export var value_B : CPMB_NumericValue

func _init() -> void:
	initialise_value()

func initialise_value(index : int = -1) -> void:
	if index == 0 or index == -1:
		value_A = CPMB_FloatValue.new(1.0)
		value_A.internal_to_node = true
	if index == 1 or index == -1:
		value_B = CPMB_FloatValue.new(0.5)
		value_B.internal_to_node = true

func get_expression() -> String:
	print("expression requested from math node")
	match operation:
		OperationType.ADD:
			return "float(" + value_A.get_expression() + ") + float(" + value_B.get_expression() + ")"
		OperationType.SUBTRACT:
			return "float(" + value_A.get_expression() + ") - float(" + value_B.get_expression() + ")"
		OperationType.MULTIPLY:
			return "float(" + value_A.get_expression() + ") * float(" + value_B.get_expression() + ")"
		OperationType.DIVIDE:
			return "float(" + value_A.get_expression() + ") / float(" + value_B.get_expression() + ")"
		
		OperationType.POWER:
			return "pow(float(" + value_A.get_expression() + "), float(" + value_B.get_expression() + "))"
		OperationType.ROOT:
			return "pow(float(" + value_A.get_expression() + "), 1.0 / float(" + value_B.get_expression() + "))"
		
	return value_A.get_expression() + " + " + value_B.get_expression()

func _to_string() -> String:
	return "Math:" + resource_scene_unique_id

func get_child_resources() -> Array[CPMB_Base]:
	return [value_A, value_B]

func get_input_port_resources() -> Dictionary[CPMB_Base, int]:
	return {
		value_A: 0,
		value_B: 1
	}

func get_node_name() -> String:
	return "utility/MathNode"
