@tool
extends CompositeMaterialBuilderGraphNode

@onready var represented_configuration : CPMB_ColorRampConfiguration = CPMB_ColorRampConfiguration.new()

func _node_ready() -> void:
	represented_configuration.gradient = GradientTexture1D.new()
	$color_ramp_preview.texture = represented_configuration.gradient
	if Engine.is_editor_hint():
		node_selected.connect(EditorInterface.edit_resource.bind(represented_configuration.gradient))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_represented_object() -> Object:
	return represented_configuration
