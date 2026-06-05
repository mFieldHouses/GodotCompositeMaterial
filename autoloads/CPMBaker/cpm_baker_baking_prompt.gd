@tool
extends Window

var current_model : CPMModel

var baking_mode_hints : Array[String] = [
	"Will bake the imported model file and replace the external materials in the import configuration with the resulting baked material. This means that every instance of this model will use the exact same textures. Very small storage usage.",
	"Will bake every instance of this model separately. This can take a while to process, depending on your hardware and the number of instances of this model. Uses a relatively large amount of storage compared to the other options, dependant on the amount of instances of this model and the quality chosen.",
	"Will only bake this instance of the model."
]

var bake_display_mode_hints : Array[String] = [
	"Will only display the baked textures and disables the procedural material.",
	"Will display the baked textures based on how far away the camera is (far away -> display baked textures), and will disable the live procedural material when the baked textures take over full visibility. Can help improve performance while retaining crisp textures when viewed up close."
]

var bake_status_hints : Array[String] = [
	"Not baked",
	"Imported model",
	"All instances",
	"This instance"
]

var resolutions : Array[Vector2i] = [
	Vector2i(128, 128),
	Vector2i(256, 256),
	Vector2i(512, 512),
	Vector2i(1024, 1024),
	Vector2i(2048, 2048),
	Vector2i(4096, 4096)
]

func _ready() -> void:
	close_requested.connect(cancel_baking_prompt)
	$MarginContainer/VBoxContainer/HBoxContainer/cancel_button.button_down.connect(cancel_baking_prompt)
	$MarginContainer/VBoxContainer/TabContainer/Bake/VBoxContainer/HBoxContainer/baking_mode.item_selected.connect(display_baking_mode_hint)
	$MarginContainer/VBoxContainer/TabContainer/Bake/VBoxContainer/HBoxContainer3/bake_display_mode.item_selected.connect(display_bake_display_mode_hint)
	
	$MarginContainer/VBoxContainer/TabContainer/Bake/VBoxContainer/bake_button.button_down.connect(bake_current_model)
	$MarginContainer/VBoxContainer/TabContainer/Revert/VBoxContainer/revert_bake_button.button_down.connect(revert_current_model)
	
	display_bake_display_mode_hint(1)
	display_baking_mode_hint(0)

func bake_current_model() -> void:
	print("baking at ", resolutions[$MarginContainer/VBoxContainer/TabContainer/Bake/VBoxContainer/HBoxContainer2/quality.selected])
	CPMBaker._bake_imported_gltf_model(current_model.scene_file_path, current_model, resolutions[$MarginContainer/VBoxContainer/TabContainer/Bake/VBoxContainer/HBoxContainer2/quality.selected])
	#current_model._internal_bake_status = 1
	cancel_baking_prompt()

func revert_current_model() -> void:
	CPMBaker._revert_imported_gltf_model(current_model.scene_file_path)
	#current_model._internal_bake_status = 0
	cancel_baking_prompt()

func bake_popup(model : CPMModel) -> void:
	current_model = model
	
	$MarginContainer/VBoxContainer/bake_status.text = "Current bake status: " + bake_status_hints[model._internal_bake_status]
	
	popup_centered(Vector2i(600, 600))

func cancel_baking_prompt() -> void:
	visible = false

func display_baking_mode_hint(index : int) -> void:
	$MarginContainer/VBoxContainer/TabContainer/Bake/VBoxContainer/baking_mode_hint_bg/MarginContainer/baking_mode_hint.text = baking_mode_hints[index]

func display_bake_display_mode_hint(index : int) -> void:
	$MarginContainer/VBoxContainer/TabContainer/Bake/VBoxContainer/bake_display_mode_hint_bg/MarginContainer/bake_display_mode_hint.text = bake_display_mode_hints[index]
