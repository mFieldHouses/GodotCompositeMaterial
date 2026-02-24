@tool
extends CompositeMaterialBuilderGraphNode

@onready var represented_gradient : GradientTexture1D = GradientTexture1D.new()

func _node_ready() -> void:
	represented_gradient.gradient = Gradient.new()
	$color_ramp_preview.texture = represented_gradient
	if Engine.is_editor_hint():
		node_selected.connect(EditorInterface.edit_resource.bind(represented_gradient))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
