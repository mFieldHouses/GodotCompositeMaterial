@tool
extends VBoxContainer

signal mesh_selected

@onready var mesh_list = get_node("mesh_list_scroll/VBoxContainer") 
@onready var background = get_parent().get_parent().get_parent().get_parent()

func setup():
	for child in mesh_list.get_children():
		if child is HBoxContainer and child.has_node("label"):
			child.get_node("label").button_down.connect(button_pressed.bind(child.name))
			child.get_node("checkbox").toggled.connect(mesh_toggled.bind(child.name))

func mesh_toggled(state : bool, mesh_name : String):
	background.mesh_configs[mesh_name].enabled = state
	background.select_mesh(mesh_name)
		
func button_pressed(button_name : String):
	mesh_selected.emit(button_name)

func enable_all_meshes(state : bool):
	for child in mesh_list.get_children():
		if child is HBoxContainer and child.has_node("label"):
			child.get_node("checkbox").button_pressed = state && !child.get_node("checkbox").disabled
	
	background.update_num_selected()

func _on_toggle_all_toggled(toggled_on: bool) -> void:
	enable_all_meshes(toggled_on)

func set_model_name(new_name : String):
	get_node("model_name").text = new_name

func toggle_all_meshes():
	for child in mesh_list.get_children():
		if child is HBoxContainer and child.has_node("label"):
			child.get_node("checkbox").button_pressed = !child.get_node("checkbox").button_pressed && !child.get_node("checkbox").disabled
	
	background.update_num_selected()


func _on_hide_unbakeable_toggled(toggled_on: bool) -> void:
	for child in mesh_list.get_children():
		if child is HBoxContainer and child.has_node("label"):
			if toggled_on:
				child.visible = !child.get_node("checkbox").disabled
			else:
				child.visible = true
