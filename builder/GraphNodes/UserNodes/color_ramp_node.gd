@tool
extends CompositeMaterialBuilderGraphNode

@onready var represented_configuration : CPMB_ColorRampConfiguration

func _node_ready() -> void:
	represented_configuration = CPMB_ColorRampConfiguration.new()
	
	$color_ramp_preview.texture = represented_configuration.gradient
	
	if Engine.is_editor_hint():
		node_selected.connect(EditorInterface.edit_resource.bind(represented_configuration.gradient))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_represented_object(port_idx : int) -> Object:
	return represented_configuration

func set_represented_object(object : Object) -> void:
	represented_configuration = object
