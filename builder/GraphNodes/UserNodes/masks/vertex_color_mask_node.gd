@tool
extends MaskNode

var represented_config : CPMB_VertexColorMaskConfiguration

# Called when the node enters the scene tree for the first time.
func _node_ready() -> void:
	represented_config = CPMB_VertexColorMaskConfiguration.new()
	
	$channel/HBoxContainer/r.pressed.connect(func(): represented_config.color = represented_config.ColorType.RED)
	$channel/HBoxContainer/g.pressed.connect(func(): represented_config.color = represented_config.ColorType.GREEN)
	$channel/HBoxContainer/b.pressed.connect(func(): represented_config.color = represented_config.ColorType.BLUE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func node_process(delta: float) -> void:
	if $channel/custom.button_pressed:
		$custom_color_config.modulate.a = 1.0
	else:
		$custom_color_config.modulate.a = 0.5
		
func get_represented_object(port_idx : int) -> Object:
	return represented_config

func set_represented_object(object : Object) -> void:
	represented_config = object
