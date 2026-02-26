@tool
extends CompositeMaterialBuilderGraphNode
class_name CompositeMaterialOutputNode

var represented_composite_material : CompositeMaterial = CompositeMaterial.new():
	set(x):
		#print("represented compositematerial changed from ", represented_composite_material, " to ", x)
		represented_composite_material = x

func _node_ready() -> void:
	get_parent().output_node = self
	
	if Engine.is_editor_hint():
		node_selected.connect(edit_material)


func edit_material() -> void:
	EditorInterface.edit_resource(represented_composite_material)


func _process(delta: float) -> void:
	move_child($new_layer, get_child_count())
	
	var _idx : int = 0
	for child in get_children():
		
		set_slot_enabled_left(_idx, false)
		
		if _idx == get_child_count() - 2:
			set_slot_color_left(_idx, Color(0.4, 1.0, 0.8, 0.2))
			set_slot_enabled_left(_idx, true)
		else:
			set_slot_color_left(_idx, Color(0.4, 1.0, 0.8, 1.0))
		_idx += 1
	
	#get_input_port_slot(get_child_count())

func add_slot() -> SubNode:
	var _new_slot = $template_slot.duplicate()
	add_child(_new_slot)
	move_child(_new_slot, get_child_count() - 3)
	_new_slot.visible = true
	
	var _new_node : SubNode = preload("res://addons/CompositeMaterial/builder/GraphNodes/UserNodes/OutputSubNode.tscn").instantiate()
	get_parent().add_child(_new_node)
	
	_new_node.linked_container = _new_slot
	_new_slot.linked_subnode = _new_node
	
	return _new_node

func request_move_slot(slot : Control, delta : int) -> void:
	if slot.get_index() + delta > 0 and slot.get_index() + delta < get_child_count() - 1:
		move_child(slot, slot.get_index() + delta)

func get_connected_layers() -> Array[GraphNode]: ##Returns an [Array] of [LayerNode]s ordered from top to bottom.
	var result : Array[GraphNode] = []
	
	for child in get_children():
		if child is SubNodeSlot and child.name != "template_slot":
			result.append(child.linked_subnode)
	
	return result
