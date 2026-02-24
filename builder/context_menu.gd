@tool
extends PopupMenu

func _ready() -> void:
	clear()
	add_submenu_node_item("Add Node...", $add_node, 0)
	
	$add_node.clear()
	$add_node.add_item("Variable")
	$add_node.add_item("Layer")
	$add_node.add_item("Texture")
	$add_node.add_item("Color Ramp")
	$add_node.add_submenu_node_item("UV", $add_node/uv)
	$add_node.add_submenu_node_item("Masks", $add_node/masks)
	$add_node.add_submenu_node_item("Utility", $add_node/utility)
	$add_node.add_item("Distance Fade")
	
	$add_node.id_pressed.connect(_add_node)
	$add_node/uv.id_pressed.connect(_add_uv_node)
	$add_node/masks.id_pressed.connect(_add_mask_node)
	$add_node/utility.id_pressed.connect(_add_utility_node)
	

func _add_node(idx : int) -> void:
	get_parent().add_node(0, idx)

func _add_uv_node(idx : int) -> void:
	get_parent().add_node(1, idx)

func _add_mask_node(idx : int) -> void:
	get_parent().add_node(2, idx)

func _add_utility_node(idx : int) -> void:
	get_parent().add_node(3, idx)
