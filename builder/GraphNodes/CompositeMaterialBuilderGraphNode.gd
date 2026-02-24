@tool
extends GraphNode
class_name CompositeMaterialBuilderGraphNode

@export var title_bar_color : Color = Color.DARK_KHAKI

func _node_ready() -> void:
	pass

func _ready() -> void:
	theme = preload("res://addons/CompositeMaterial/builder/graph_node_default_theme.tres")
	_node_ready()

#func _gui_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#print("clicked on node")
