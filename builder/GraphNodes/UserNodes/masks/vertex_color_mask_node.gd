@tool
extends MaskNode

var represented_config : CPMB_VertexColorMaskConfiguration = CPMB_VertexColorMaskConfiguration.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $channel/custom.button_pressed:
		$custom_color_config.modulate.a = 1.0
	else:
		$custom_color_config.modulate.a = 0.5
		
func get_represented_object() -> Object:
	return represented_config
