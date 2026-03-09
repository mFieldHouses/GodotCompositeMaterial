@tool
extends CPMB_FloatValue
class_name CPMB_TimeConfig

@export var scale : CPMB_FloatValue

func _init(value : float = 0.0) -> void:
	initialise_value()

func initialise_value(index : int = -1) -> void:
	scale = CPMB_FloatValue.new(1.0)

func get_expression() -> String:
	return "TIME * %s" % scale.get_expression()

func _to_string() -> String:
	return "TimeConfig:" + resource_scene_unique_id
