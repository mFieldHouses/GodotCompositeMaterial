@tool
extends CompositeMaterialBuilderGraphNode
class_name SubNode

var linked_container : Control
var linked_node : GraphNode

signal node_wants_to_be_rearranged

# Called when the node enters the scene tree for the first time.
func _node_ready() -> void:
	
	await get_tree().create_timer(0.05).timeout
	
	var _up_button := Button.new()
	_up_button.icon = preload("res://addons/CompositeMaterial/builder/ArrowUp.svg")
	get_titlebar_hbox().add_child(_up_button)
	_up_button.button_down.connect(linked_container.get_parent().request_move_slot.bind(linked_container, -1))
	
	var _down_button := Button.new()
	_down_button.icon = preload("res://addons/CompositeMaterial/builder/ArrowDown.svg")
	get_titlebar_hbox().add_child(_down_button)
	_down_button.button_down.connect(linked_container.get_parent().request_move_slot.bind(linked_container, 1))
	
	var _remove_button : Button = Button.new()
	_remove_button.text = " - "
	_remove_button.add_theme_stylebox_override("normal", preload("res://addons/CompositeMaterial/builder/removal_button_stylebox.tres"))
	_remove_button.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_remove_button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	get_titlebar_hbox().add_child(_remove_button)
	get_titlebar_hbox().size.y = 0
	
	_remove_button.pressed.connect(queue_free)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print("process")
	if linked_container == null:
		#print("no linked container")
		return
	else:
		title = linked_node.title
	
	position_offset = linked_container.position + linked_container.get_parent().position_offset - Vector2(40.0, 0.0)


func _exit_tree() -> void:
	if linked_container:
		linked_container.queue_free()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			selected = true
		else:
			selected = false
