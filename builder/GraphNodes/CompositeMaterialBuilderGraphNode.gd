@tool
extends GraphNode
class_name CompositeMaterialBuilderGraphNode

@export var title_bar_color : Color = Color.DARK_KHAKI

func _node_ready() -> void: ##Called after _ready() by [CompositeMaterialBuilderGraphNode] to allow extending classes to extend _ready() functionality without overriding base behavior.
	pass

func _ready() -> void:
	theme = preload("res://addons/CompositeMaterial/builder/graph_node_default_theme.tres")
	_node_ready()

#func _gui_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#print("clicked on node")

func connect_and_pass_object(input_port_id : int, object : Object) -> void: ##Override this method to be able to process connections.
	pass

func get_represented_object(port_idx : int) -> Object: ##This method must be overridden to provide values in the case of connections.
	return null

func set_represented_object(object : Object) -> void:
	pass
