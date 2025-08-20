@tool
extends TabContainer

@onready var background = get_parent().get_parent().get_parent().get_parent().get_parent()

@onready var config_options_popup : PopupMenu = get_node("Mesh/VBoxContainer/header/VBoxContainer/source_mesh_name/options").get_popup()

func _ready():
	config_options_popup.index_pressed.connect(config_option_pressed)

func _process(delta: float) -> void:
	if background:
		get_node("Mesh/VBoxContainer/header/VBoxContainer/source_mesh_name/options").get_popup().set_item_disabled(5, background.currently_copied_config == null)
	pass

func config_option_pressed(idx : int):
	match idx:
		0:
			background.copy_current_config()
		1:
			background.paste_onto_current_config()
		4:
			background.copy_current_config_to_all()
