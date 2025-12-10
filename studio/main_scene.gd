@tool
extends Control

var _scene_configs : Dictionary[String, Dictionary]
var _currently_loaded_config : Dictionary

signal tab_pressed(idx : int)
signal config_loaded(scene_instance : Node3D)

var _mouse_in_viewport : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBox/TabBar.tab_changed.connect(_show_model)
	
	$VBox/Viewport/SubViewportContainer.mouse_entered.connect(func(): _mouse_in_viewport = true)
	$VBox/Viewport/SubViewportContainer.mouse_exited.connect(func(): _mouse_in_viewport = false)
	
	$VBox/Viewport/toolbar/HBoxContainer/reference_model.get_popup().id_pressed.connect(_reference_model_option_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _reference_model_option_pressed(id : int) -> void:
	match id:
		0:
			var new_file_dialog = EditorFileDialog.new()
			new_file_dialog.title = "Open reference model/scene"
			new_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
			new_file_dialog.set_filters(PackedStringArray(["*.gltf, *.fbx, *.obj ; 3D Models","*.tscn, *.scn ; Godot Scenes"]))
			
			add_child(new_file_dialog)
			new_file_dialog.file_selected.connect(_load_reference_model)
			new_file_dialog.canceled.connect(new_file_dialog.queue_free)
			new_file_dialog.popup_centered(Vector2i(800,600))


func _load_reference_model(path : String) -> void:
	print(_currently_loaded_config)
	_currently_loaded_config.reference_model.path = path
	
	if _currently_loaded_config.reference_model.instance != null:
		_currently_loaded_config.reference_model.instance.queue_free()
	
	var _reference_instance = load(path).instantiate()
	_currently_loaded_config.reference_model.instance = _reference_instance
	_currently_loaded_config.reference_model.path = path
	_reference_instance.set_meta("reference_model", true)
	_currently_loaded_config.instance.add_child(_reference_instance)
	_reference_instance.position = Vector3(0.0, 0.0, 3.0)


func _on_load_button_down() -> void:
	var new_file_dialog = EditorFileDialog.new()
	new_file_dialog.title = "Open model/scene"
	new_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	new_file_dialog.set_filters(PackedStringArray(["*.gltf, *.fbx, *.obj ; 3D Models","*.tscn, *.scn ; Godot Scenes"]))
	
	add_child(new_file_dialog)
	new_file_dialog.file_selected.connect(_load_model)
	new_file_dialog.canceled.connect(new_file_dialog.queue_free)
	new_file_dialog.popup_centered(Vector2i(800,600))

func _load_model(path : String) -> void:
	$VBox/TabBar.add_tab(path.get_file())
	$VBox/Toolbar/Load.release_focus()
	
	var _new_model_instance = load(path).instantiate()
	$VBox/Viewport/SubViewportContainer/SubViewport.add_child(_new_model_instance)
	_scene_configs.get_or_add(path, {"instance": _new_model_instance, "reference_model": {"path": "", "instance": null, "position": Vector3(0.0, 0.0, 3.0)}})
	$VBox/TabBar.current_tab = _scene_configs.size() - 1
	
	config_loaded.emit(_scene_configs[path])
	_currently_loaded_config = _scene_configs[path]
	
	print(_scene_configs)

func _show_model(index : int) -> void:
	var _idx : int = 0
	for _config in _scene_configs:
		if _idx == index:
			_scene_configs[_config].instance.visible = true
			_currently_loaded_config = _scene_configs[_config]
			config_loaded.emit(_scene_configs[_config])
		else:
			_scene_configs[_config].instance.visible = false
		
		_idx += 1
	
	tab_pressed.emit(index)

func _input(event: InputEvent) -> void:
	if _mouse_in_viewport:
		$VBox/Viewport/SubViewportContainer/SubViewport/camera_pivot/camera.input_event(event)
