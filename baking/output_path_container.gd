@tool
extends HBoxContainer

@onready var background = get_tree().get_nodes_in_group("bake_interface_root")[1] #Waarom zijn er altijd 2 backgrounds????

func _ready() -> void:
	$options.get_popup().id_pressed.connect(select_option)
	print(get_tree().get_nodes_in_group("bake_interface_root"))

func select_option(id):
	match id:
		0:
			background.copy_property_to_all("output_path")
		1:
			background.copy_property_to_enabled("output_path", true)
		2:
			background.copy_property_to_enabled("output_path", false)
