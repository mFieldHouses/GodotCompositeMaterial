@tool
extends VBoxContainer

var paths : Dictionary = {}

func new_texture(texture_id : String, texture_path : String):
	
	var new_item = $empty.duplicate()
	new_item.name = texture_id
	new_item.visible = true
	new_item.get_node("texture_id").text = texture_id
	new_item.get_node("texture_path").text = texture_path
	
	paths.get_or_add(texture_id)
	paths[texture_id] = texture_path
	
	add_child(new_item)
	move_child($add_button_container, get_children().size() - 1)

func get_path_for_id(identifier : String) -> String:
	if paths.has(identifier):
		return paths[identifier]
	else:
		return ""

func set_path_for_id(identifier : String, path : String):
	if paths.has(identifier):
		paths[identifier] = path
