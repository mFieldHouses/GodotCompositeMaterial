@tool
extends CompositeMaterialBuilderGraphNode

@export var respresented_texture : Texture2D

func _node_ready() -> void:
	$load_texture.button_down.connect(_load_texture)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _load_texture() -> void:
	var _file_dialog : EditorFileDialog = EditorFileDialog.new()
	add_child(_file_dialog)
	
	_file_dialog.filters = ["*.png,*.jpg,*.jpeg;Image Files"]
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	
	_file_dialog.popup_centered(Vector2i(600,400))
	_file_dialog.close_requested.connect(_file_dialog.queue_free)
	
	var path : String = await _file_dialog.file_selected
	respresented_texture = load(path)
	$texture_view.texture = respresented_texture
	
