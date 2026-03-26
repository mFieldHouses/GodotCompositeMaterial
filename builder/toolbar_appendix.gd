@tool
extends HBoxContainer

signal set_auto_rebuild(new_state : bool)
signal rebuild_manual

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$rebuild.icon = EditorInterface.get_base_control().get_theme_icon("Reload", "EditorIcons")
	$rebuild.button_down.connect(rebuild_manual.emit)
	
	$auto_rebuild.toggled.connect(func(state : bool): set_auto_rebuild.emit(state))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
