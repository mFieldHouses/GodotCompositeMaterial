@tool
extends CompositeMaterialBuilderGraphNode
class_name FunctionNode

enum FunctionType {
	LINEAR, BIASGAIN, STEPS
}

var represented_config : CPMB_Function

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	represented_config = CPMB_Function.new()
	
	$function.item_selected.connect(change_function)
	change_function(0)
	
	$settings_linear/slope_value.value_changed.connect(func(x): represented_config.function_arg_1.value = x; set_preview_arg(0, x))
	$settings_linear/offset_value.value_changed.connect(func(x): represented_config.function_arg_2.value = x; set_preview_arg(1, x))
	
	$settings_bias_gain/s_value.value_changed.connect(func(x): represented_config.function_arg_2.value = x; set_preview_arg(1, x))
	$settings_bias_gain/t_value.value_changed.connect(func(x): represented_config.function_arg_1.value = x; set_preview_arg(0, x))
	
	
func set_preview_arg(index : int, value : Variant) -> void:
	var args = $preview_window.function_args
	args[index] = value
	$preview_window.function_args = args
	
func change_function(idx : int) -> void:
	represented_config.function = idx
	represented_config.initialise_function_type(represented_config.function)
	
	$settings_bias_gain.visible = false
	$settings_linear.visible = false
	$settings_steps.visible = false
	
	match idx:
		0:
			$settings_linear.visible = true
			$settings_linear/slope_value.value = 1.0
			set_preview_arg(0, 1.0)
			$settings_linear/offset_value.value = 0.0
			set_preview_arg(1, 0.0)
		1:
			$settings_bias_gain.visible = true
			$settings_bias_gain/t_value.value = 0.5
			set_preview_arg(0, 0.5)
			$settings_bias_gain/s_value.value = 1.0
			set_preview_arg(1, 1.0)
		2:
			$settings_steps.visible = true

func get_represented_object(port_idx : int) -> Object:
	return represented_config

func set_represented_object(object : Object) -> void:
	represented_config = object
	
	$function.selected = represented_config.function
	change_function(represented_config.function)

func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	match input_port_id:
		0:
			represented_config.X = object
