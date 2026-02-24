@tool
extends GraphEdit

var output_node : CompositeMaterialOutputNode

var node_mappings : Array = [
	["VariableNode", "LayerNode", "TextureNode", "ColorRampNode", "", "", "", "DistanceFadeNode"],
	["UVTransformNode","UVMapNode","TriplanarMapNode"],
	["masks/CompileMasksNode", "masks/DirectionalMaskNode", "masks/PositionalMaskNode", "masks/UVMaskNode", "masks/VertexColorMaskNode", "masks/NormalMapMaskNode"],
	["utility/MathNode", "utility/DecomposeAlbedoNode", "utility/ComposeAlbedoNode"]
]

var dynamic_nodes : Array[GraphNode] = []

var selected_node : GraphNode

func _ready() -> void:
	connection_request.connect(_connection_requested)
	$context_menu.id_pressed.connect(_context_menu_option_pressed)
	
	node_selected.connect(func(node): selected_node = node)
	node_deselected.connect(func(node): selected_node = null)
	
	#for child in get_children():
		#if child is CompileMasksSubNode:
			#child.queue_free()
	

func _process(delta: float) -> void:
	if output_node:
		if get_connection_count(output_node.name, output_node.get_child_count() - 1) > 0:
			var _label : Label = Label.new()
			_label.text = "Layer"
			output_node.add_child(_label)
	
	for dyn_node in dynamic_nodes:
		if dyn_node is CompileMasksNode:
			if get_connection_count(dyn_node.name, dyn_node.get_child_count() - 3) > 0:
				dyn_node.add_slot()
	
	#print(scroll_offset)

func _connection_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	#print("request for connection: port ", from_port, " on ", from_node, " to port ", to_port, " on ", to_node)
	
	for connection in get_connection_list_from_node(to_node):
		print(connection.to_port)
		if connection.to_port == to_port and connection.to_node == to_node: #if we already have a connection running to the target port
			print("already a connection in place")
			return
	
	if from_node == to_node:
		print("connecting to itself")
		return
	
	if get_node(String(to_node)) is CompileMasksNode:
		var _new_node = get_node(String(to_node)).add_slot()
		connect_node(from_node, from_port, _new_node.name, 0)
		return
	
	connect_node(from_node, from_port, to_node, to_port)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.pressed:
			return
		
		if event.button_index == MOUSE_BUTTON_RIGHT:
			$context_menu.popup(Rect2i(get_global_mouse_position(), Vector2i(100,100)))
	
	elif event is InputEventKey:
		if event.keycode == KEY_DELETE or event.keycode == KEY_BACKSPACE and event.pressed:
			if selected_node is not CompositeMaterialOutputNode:
				selected_node.queue_free()
				selected_node = null
			

func _context_menu_option_pressed(option_id : int) -> void:
	print(option_id)

func add_node(idx1 : int, idx2 : int) -> void:
	var _node_name = node_mappings[idx1][idx2]
	instantiate_node_at_mouse(_node_name)
	
func instantiate_node_at_mouse(node_name : String) -> void:
	var _node = load("res://addons/CompositeMaterial/builder/GraphNodes/UserNodes/" + node_name + ".tscn").instantiate()
	add_child(_node)
	_node.global_position = get_global_mouse_position()

func register_dynamic_node(node : GraphNode) -> void:
	if !dynamic_nodes.has(node):
		dynamic_nodes.append(node)

func deregister_dynamic_node(node : GraphNode) -> void:
	if dynamic_nodes.has(node):
		dynamic_nodes.erase(node)
