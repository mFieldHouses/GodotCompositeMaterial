@tool
extends CPMB_FloatValue
class_name CPMB_Function

enum FunctionType {
	LINEAR,
	BIASGAIN,
	STEPS
}

@export var X : CPMB_NumericValue:
	set(x):
		X = x

@export var function : FunctionType = 0:
	set(x):
		function = x
		request_material_rebuild.emit()

@export var function_arg_1 : CPMB_NumericValue
@export var function_arg_2 : CPMB_NumericValue
@export var function_arg_3 : CPMB_NumericValue

func _init() -> void:
	initialise_value()

func initialise_value(index : int = -1) -> void:
	if index == 0 or index == -1:
		X = CPMB_FloatValue.new(0.5)
		X.internal_to_node = true

func initialise_function_type(type : FunctionType) -> void:
	match type:
		FunctionType.LINEAR:
			function_arg_1 = CPMB_FloatValue.new(1.0) #slope
			function_arg_1.internal_to_node = true
			function_arg_2 = CPMB_FloatValue.new(0.0) #offset
			function_arg_2.internal_to_node = true
			function_arg_3 = null
		FunctionType.BIASGAIN:
			function_arg_1 = CPMB_FloatValue.new(1.0) #slope
			function_arg_1.internal_to_node = true
			function_arg_2 = CPMB_FloatValue.new(0.0) #offset
			function_arg_2.internal_to_node = true
			function_arg_3 = null
		FunctionType.STEPS:
			function_arg_1 = CPMB_IntValue.new(5) #steps
			function_arg_1.internal_to_node = true
			function_arg_2 = CPMB_IntValue.new(0) #type
			function_arg_2.internal_to_node = true
			function_arg_3 = null

func get_expression() -> String:
	match function:
		FunctionType.LINEAR:
			return "func_linear(%s, %s, %s)" % [X.get_expression(), function_arg_1.get_expression(), function_arg_2.get_expression()]
		FunctionType.BIASGAIN:
			return "func_bias_gain(%s, %s, %s)" % [X.get_expression(), function_arg_1.get_expression(), function_arg_2.get_expression()]
		
	return "func_linear(%s, %s, %s)" % [X.get_expression(), function_arg_1.get_expression(), function_arg_2.get_expression()]
	
func _to_string() -> String:
	return "Function:" + resource_scene_unique_id

func get_child_resources() -> Array[CPMB_Base]:
	return [X, function_arg_1, function_arg_2]

func get_input_port_resources() -> Dictionary[CPMB_Base, int]:
	return {
		X: 0
	}

func get_node_name() -> String:
	return "convert/FunctionNode"
