extends Resource
class_name CPMB_Base

var internal_to_node : bool = false
var index : int = 0: ##Index of this resource in the shader uniform arrays. Used to build the returned expression.
	set(x):
		index = x
		#print("index got set to ", x, " for ", self)
		
func get_expression() -> String: ##Must be overridden. Returns an expression in GDShader syntax.
	return ""

func get_output_port_for_state() -> int:
	return 0

func call_setters() -> void: ##Override this in extending classes
	pass
