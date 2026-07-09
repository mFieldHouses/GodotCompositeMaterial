@tool
extends Window

var current_material : CompositeMaterial

func _ready() -> void:
	visible = false
	
	close_requested.connect(close)
	$MarginContainer/VBoxContainer/HBoxContainer/cancel_button.button_down.connect(close)
	$MarginContainer/VBoxContainer/HBoxContainer/bake_button.button_down.connect(bake)
	
func bake() -> void:
	CPMBaker.bake_surface(current_material, Vector2i(512, 512), $MarginContainer/VBoxContainer/surface_size/surface_size.value, $MarginContainer/VBoxContainer/axis/axis.selected)
	close()
	
func pop_up(material : CompositeMaterial) -> void:
	popup_centered(Vector2i(400, 400))
	current_material = material
	initialize()

func initialize() -> void:
	$MarginContainer/VBoxContainer/surface_size/surface_size.value = 1.0
	$MarginContainer/VBoxContainer/axis/axis.select(1)

func close() -> void:
	visible = false
