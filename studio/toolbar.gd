@tool
extends HBoxContainer

func _ready() -> void:
	$View.get_popup().id_pressed.connect(_view_option_pressed)

func _view_option_pressed(id : int) -> void:
	match id:
		0:
			%grid_settings.popup_centered(Vector2i(300, 200))

func _environment_option_pressed(id : int) -> void:
	match id:
		0:
			pass
