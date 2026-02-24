@tool
extends CompositeMaterialBuilderGraphNode
class_name CompositeMaterialOutputNode

func _node_ready() -> void:
	#print("ready 2")
	#title = "CompositeMaterial"
	#print(get_children(true))
	#for i in get_children(true):
		#print(i.get_children(true))
	#get_titlebar_hbox().visible = false
	#get_titlebar_hbox().get_child(0)
	get_parent().output_node = self
	pass

func _process(delta: float) -> void:
	move_child($new_layer, get_child_count())
	
	var _idx : int = 0
	for child in get_children():
		
		set_slot_enabled_left(_idx, true)
		
		if _idx == get_child_count() - 1:
			set_slot_color_left(_idx, Color(0.4, 1.0, 0.8, 0.2))
		else:
			set_slot_color_left(_idx, Color(0.4, 1.0, 0.8, 1.0))
		_idx += 1
	
	#get_input_port_slot(get_child_count())
