@tool
extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_load_button_down() -> void:
	var new_file_dialog = EditorFileDialog.new()
	new_file_dialog.title = "Open model/scene"
	new_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	new_file_dialog.set_filters(PackedStringArray(["*.gltf, *.fbx, *.obj ; 3D Models","*.tscn ; Godot Scenes"]))
	
	add_child(new_file_dialog)
	new_file_dialog.file_selected.connect(open_model)
	new_file_dialog.canceled.connect(new_file_dialog.queue_free)
	new_file_dialog.popup_centered(Vector2i(800,600))

func open_model(path : String):
	print("test")
