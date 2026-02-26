@tool
extends CompositeMaterialBuilderGraphNode
class_name CompileMasksNode

var represented_configuration : CPMB_CompileMasksConfiguration = CPMB_CompileMasksConfiguration.new()

# Called when the node enters the scene tree for the first time.
func _node_ready() -> void:
	get_parent().register_dynamic_node(self)

func _exit_tree() -> void:
	get_parent().deregister_dynamic_node(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in get_child_count():
		if i == get_child_count() - 3:
			set_slot_enabled_left(i, true)
			set_slot_enabled_right(i, false)
			set_slot_type_left(i, 5)
		elif i == get_child_count() - 2:
			set_slot_enabled_right(i, true)
			set_slot_enabled_left(i, false)
			set_slot_type_left(i, 5)
		else:
			set_slot_enabled_left(i, false)
			set_slot_enabled_right(i, false)
	
	for child in get_children():
		if child.has_meta("is_slot"):
			child.get_node("operation").visible = child.get_index() != get_child_count() - 3

func add_slot() -> SubNode:
	var _new_slot = $template_slot.duplicate()
	add_child(_new_slot)
	move_child(_new_slot, get_child_count() - 3)
	_new_slot.visible = true
	
	var _new_node : SubNode = preload("res://addons/CompositeMaterial/builder/GraphNodes/UserNodes/CompileMasksSubNode.tscn").instantiate()
	get_parent().add_child(_new_node)
	
	_new_node.linked_container = _new_slot
	_new_slot.linked_subnode = _new_node
	
	return _new_node

func request_move_slot(slot : Control, delta : int) -> void:
	if slot.get_index() + delta > 0 and slot.get_index() + delta < get_child_count() - 2:
		move_child(slot, slot.get_index() + delta)

func get_represented_object() -> Object:
	return represented_configuration

func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	represented_configuration.masks.append(object)
	if represented_configuration.operations.size() > 1:
		represented_configuration.operations.append(0)
