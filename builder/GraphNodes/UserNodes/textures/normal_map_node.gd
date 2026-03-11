@tool
extends CompositeMaterialBuilderGraphNode
class_name NormalMapNode

var represented_normal_map_config : CPMB_NormalMapConfiguration

func _node_ready() -> void:
	$load_texture.button_down.connect(_load_texture)
	$scale.value_changed.connect(func(x): represented_normal_map_config.scale = x)
	
	represented_normal_map_config = CPMB_NormalMapConfiguration.new()
	
	if Engine.is_editor_hint():
		node_selected.connect(edit_texture)

func _process(delta: float) -> void:
	size.y = 0

func _load_texture() -> void:
	var _file_dialog : EditorFileDialog = EditorFileDialog.new()
	add_child(_file_dialog)
	
	_file_dialog.filters = ["*.png,*.jpg,*.jpeg;Image Files"]
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	
	_file_dialog.popup_centered(Vector2i(600,400))
	_file_dialog.close_requested.connect(_file_dialog.queue_free)
	
	var path : String = await _file_dialog.file_selected
	var tex = load(path)
	represented_normal_map_config.normal_map = tex
	$FoldableContainer/texture_view.texture = tex
	$FoldableContainer.folded = false

func edit_texture() -> void:
	EditorInterface.edit_resource(represented_normal_map_config)

func get_represented_object(port_idx : int) -> Object:
	return represented_normal_map_config

func set_represented_object(object : Object) -> void:
	represented_normal_map_config = object
	$FoldableContainer/texture_view.texture = object.normal_map
	$scale.value = object.scale

func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	match input_port_id:
		0:
			represented_normal_map_config.uv = object

func disconnected(input_port_id : int) -> void:
	represented_normal_map_config.initialise_value(input_port_id)
