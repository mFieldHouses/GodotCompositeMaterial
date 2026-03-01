@tool
extends MaskNode

var represented_config : CPMB_VertexColorMaskConfiguration

# Called when the node enters the scene tree for the first time.
func _node_ready() -> void:
	represented_config = CPMB_VertexColorMaskConfiguration.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $channel/custom.button_pressed:
		$custom_color_config.modulate.a = 1.0
	else:
		$custom_color_config.modulate.a = 0.5
		
func get_represented_object(port_idx : int) -> Object:
	return represented_config

func set_represented_object(object : Object) -> void:
	represented_config = object
