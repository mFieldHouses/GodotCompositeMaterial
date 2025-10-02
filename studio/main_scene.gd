@tool
extends Control

var _loaded_model_instances : Dictionary[String, Node3D] = {}
var _currently_loaded_model : Node3D

signal tab_pressed(idx : int)
signal scene_loaded(scene_instance : Node3D)

var _mouse_in_viewport : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBox/TabBar.tab_changed.connect(_show_model)
	
	$VBox/Viewport/SubViewportContainer.mouse_entered.connect(func(): _mouse_in_viewport = true)
	$VBox/Viewport/SubViewportContainer.mouse_exited.connect(func(): _mouse_in_viewport = false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_load_button_down() -> void:
	var new_file_dialog = EditorFileDialog.new()
	new_file_dialog.title = "Open model/scene"
	new_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	new_file_dialog.set_filters(PackedStringArray(["*.gltf, *.fbx, *.obj ; 3D Models","*.tscn ; Godot Scenes"]))
	
	add_child(new_file_dialog)
	new_file_dialog.file_selected.connect(_load_model)
	new_file_dialog.canceled.connect(new_file_dialog.queue_free)
	new_file_dialog.popup_centered(Vector2i(800,600))

func _load_model(path : String) -> void:
	$VBox/TabBar.add_tab(path.get_file())
	$VBox/Toolbar/Load.release_focus()
	
	var _new_model_instance = load(path).instantiate()
	$VBox/Viewport/SubViewportContainer/SubViewport.add_child(_new_model_instance)
	_loaded_model_instances.get_or_add(path, _new_model_instance)
	$VBox/TabBar.current_tab = _loaded_model_instances.size() - 1
	
	scene_loaded.emit(_new_model_instance)

func _show_model(index : int) -> void:
	var _idx : int = 0
	for _model_path in _loaded_model_instances:
		if _idx == index:
			_loaded_model_instances[_model_path].visible = true
			_currently_loaded_model = _loaded_model_instances[_model_path]
			scene_loaded.emit(_loaded_model_instances[_model_path])
		else:
			_loaded_model_instances[_model_path].visible = false
		
		_idx += 1
	
	tab_pressed.emit(index)

func _input(event: InputEvent) -> void:
	if _mouse_in_viewport:
		$VBox/Viewport/SubViewportContainer/SubViewport/camera_pivot/camera.input_event(event)
