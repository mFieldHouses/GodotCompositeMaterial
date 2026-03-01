extends Resource
class_name CPMB_Base

var index : int = 0 ##Index of this resource in the shader uniform arrays. Used to build the returned expression.

func get_expression() -> String: ##Must be overridden. Returns an expression in GDShader syntax.
	return ""

func get_output_port_for_state() -> int:
	return 0
