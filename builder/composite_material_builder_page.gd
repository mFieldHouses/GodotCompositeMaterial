@tool
extends GraphEdit
class_name CompositeMaterialBuilderPage

var output_node : CompositeMaterialOutputNode

var node_mappings : Array = [
	["VariableNode", "LayerNode", "TextureNode", "ColorRampNode", "", "", "", "DistanceFadeNode"],
	["UVTransformNode","UVMapNode","TriplanarMapNode"],
	["masks/CompileMasksNode", "masks/DirectionalMaskNode", "masks/PositionalMaskNode", "masks/UVMaskNode", "masks/VertexColorMaskNode", "masks/NormalMapMaskNode"],
	["vector/VectorMathNode", "vector/ComposeVector2Node", "vector/DecomposeVector2Node", "vector/ComposeVector3Node", "vector/DecomposeVector3Node", "vector/ComposeVector4Node", "vector/DecomposeVector4Node"],
	["utility/MathNode", "utility/ComposeAlbedoNode"]
]

var dynamic_nodes : Array[GraphNode] = []

var selected_node : GraphNode

var edited_composite_material : CompositeMaterial = CompositeMaterial.new()

var node_groups : Dictionary[String, Array] = {
	"layers": [],
	"textures": [],
	"color_ramps": [],
	"mask_compilers": [],
	"masks": []
}

func _ready() -> void:
	connection_request.connect(_connection_requested)
	disconnection_request.connect(_disconnection_request)
	$context_menu.id_pressed.connect(_context_menu_option_pressed)
	
	node_selected.connect(func(node): selected_node = node)
	node_deselected.connect(func(node): selected_node = null)
	
	output_node = $output
	
	#for child in get_children():
		#if child is CompileMasksSubNode:
			#child.queue_free()
	

func _process(delta: float) -> void:
	pass
	#
	#for layer_node : LayerNode in node_groups.layers:
		#for connection in get_connection_list_from_node(layer_node.name):
			#if connection.to_node == layer_node.name:
				#pass
				#print(connection.to_port)
	
	#if output_node:
		#if get_connection_count(output_node.name, output_node.get_child_count() - 1) > 0:
			#var _label : Label = Label.new()
			#_label.text = "Layer"
			#output_node.add_child(_label)
	#
	#for dyn_node in dynamic_nodes:
		#if dyn_node is CompileMasksNode:
			#if get_connection_count(dyn_node.name, dyn_node.get_child_count() - 3) > 0:
				#dyn_node.add_slot()
	
	#print(scroll_offset)

func _connection_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	#print("request for connection: port ", from_port, " on ", from_node, " to port ", to_port, " on ", to_node)
	
	var _from_node : CompositeMaterialBuilderGraphNode = get_node(String(from_node))
	var _to_node : CompositeMaterialBuilderGraphNode = get_node(String(to_node))
	
	for connection in get_connection_list_from_node(to_node):
		#print(connection.to_port)
		if connection.to_port == to_port and connection.to_node == to_node: #if we already have a connection running to the target port
			print("already a connection in place")
			return
	
	if from_node == to_node:
		print("connecting to itself")
		return
	
	#if _to_node is CompileMasksNode:
		#var _new_node = _to_node.add_slot()
		#_new_node.linked_node = _from_node
		#connect_node(from_node, from_port, _new_node.name, 0)
		#_to_node.connect_and_pass_object(to_port, _from_node.get_represented_object(from_port))
		#build_material()
		#return
	elif _to_node is CompositeMaterialOutputNode:
		var _new_node = get_node(String(to_node)).add_slot()
		_new_node.linked_node = get_node(String(from_node))
		connect_node(from_node, from_port, _new_node.name, 0)
		_to_node.connect_and_pass_object(to_port, _from_node.get_represented_object(from_port))
		build_material()
		return
	elif _to_node is LayerNode:
		if to_port == 2:
			_to_node.enable_value(0, false)
		elif to_port == 3:
			_to_node.enable_value(1, false)
	
	connect_node(from_node, from_port, to_node, to_port)
	_to_node.connect_and_pass_object(to_port, _from_node.get_represented_object(from_port))
	
	build_material()


func _disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	
	print("disconnection")
	
	var _from_node : GraphNode = get_node(String(from_node))
	var _to_node : GraphNode = get_node(String(to_node))
	
	if _to_node is LayerNode:
		if to_port == 2:
			_to_node.enable_value(0, true)
		elif to_port == 3:
			_to_node.enable_value(1, true)


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
	
	if _node is LayerNode:
		_node.name = "layer" + str(node_groups.layers.size())
		add_node_to_group(_node, "layers")
	elif _node is MaskNode:
		add_node_to_group(_node, "masks")
	
	_node.global_position = get_global_mouse_position()

func add_node_to_group(node : GraphNode, group_name : String) -> void:
	if node_groups.has(group_name):
		if !node_groups[group_name].has(node):
			node_groups[group_name].append(node)

func remove_node_from_groups(node : GraphNode) -> void:
	for key in node_groups.keys():
		if node_groups[key].has(node):
			node_groups[key].erase(node)

func register_dynamic_node(node : GraphNode) -> void:
	if !dynamic_nodes.has(node):
		dynamic_nodes.append(node)

func deregister_dynamic_node(node : GraphNode) -> void:
	if dynamic_nodes.has(node):
		dynamic_nodes.erase(node)

func build_material() -> void:
	#Clear out material
	edited_composite_material.layers = [] as Array[CompositeMaterialLayer]
	
	#Map out all used resources
	var mapped_resources : Dictionary[String, Array] = {
		"DirectionalMaskConfiguration": [],
		"PositionalMaskConfiguration": [],
		"VertexColorMaskConfiguration": [],
		
		"UVTransformConfiguration": [],
		"UVMapConfiguration": [],
		"TriplanarUVConfiguration": [],
		
		"TextureConfiguration": [],
		"Texture": [],
		
		"IntValue": [],
		"FloatValue": [],
		"Vector2Value": [],
		"Vector3Value": [],
		"Vector4Value": []
	}
	
	var resources_to_check : Array[Resource] = []
	
	var append_resource_to_mapped_resources : Callable = func(resource : CPMB_Base, array_name : String) -> void:
		resource.index = mapped_resources[array_name].size()
		mapped_resources[array_name].append(resource)
	
	#Initialize resources_to_check with resources in all layers
	for subnode : SubNode in $output.get_connected_layers():
		var represented_layer : CompositeMaterialLayer = subnode.linked_node.represented_layer
		material.layers.append(represented_layer)
		
		if represented_layer.albedo:
			resources_to_check.append(represented_layer.albedo)
		if represented_layer.normal:
			resources_to_check.append(represented_layer.normal)
		if represented_layer.roughness_value:
			resources_to_check.append(represented_layer.roughness_value)
		if represented_layer.metallic_value:
			resources_to_check.append(represented_layer.metallic_value)
		if represented_layer.mask:
			resources_to_check.append(represented_layer.mask)
	
	
	#Go through resources_to_check and expand where neccesary until all resources have been checked and/or mapped.
	while resources_to_check.size() > 0:
		var resource_to_check : Resource = resources_to_check.pop_front()
		
		if resource_to_check is CPMB_DirectionalMaskConfiguration:
			append_resource_to_mapped_resources.call(resource_to_check, "DirectionalMaskConfiguration")
		elif resource_to_check is CPMB_PositionalMaskConfiguration:
			append_resource_to_mapped_resources.call(resource_to_check, "PositionalMaskConfiguration")
		elif resource_to_check is CPMB_VertexColorMaskConfiguration:
			append_resource_to_mapped_resources.call(resource_to_check, "VertexColorMaskConfiguration")
		elif resource_to_check is CPMB_UVMapConfiguration:
			append_resource_to_mapped_resources.call(resource_to_check, "UVMapConfiguration")
		elif resource_to_check is CPMB_UVTransformConfiguration:
			append_resource_to_mapped_resources.call(resource_to_check, "UVTransformConfiguration")
			resources_to_check.append(resource_to_check.base_uv)
			resources_to_check.append(resource_to_check.offset)
			resources_to_check.append(resource_to_check.scale)
		elif resource_to_check is CPMB_TextureConfiguration:
			append_resource_to_mapped_resources.call(resource_to_check, "TextureConfiguration")
			mapped_resources.Texture.append(resource_to_check.texture)
			resources_to_check.append(resource_to_check.uv)
		elif resource_to_check is CPMB_ColorRampConfiguration:
			mapped_resources.Texture.append(resource_to_check.gradient)
			resources_to_check.append(resource_to_check.fac)
		
		#these are base classes, classes that extend these should be checked for first
		elif resource_to_check is CPMB_Vector2Value:
			append_resource_to_mapped_resources.call(resource_to_check, "Vector2Value")
		elif resource_to_check is CPMB_Vector3Value:
			append_resource_to_mapped_resources.call(resource_to_check, "Vector3Value")
		elif resource_to_check is CPMB_Vector4Value:
			append_resource_to_mapped_resources.call(resource_to_check, "Vector4Value")
		elif resource_to_check is CPMB_IntValue:
			append_resource_to_mapped_resources.call(resource_to_check, "IntValue")
		elif resource_to_check is CPMB_FloatValue:
			append_resource_to_mapped_resources.call(resource_to_check, "FloatValue")
	
	edited_composite_material.shader = Shader.new()
	edited_composite_material.shader.code = preload("res://addons/CompositeMaterial/shaders/CompositeMaterialBase.gdshader").code
	
	var definition_map : Dictionary[String, String] = {
		"DirectionalMaskConfiguration" : "NUM_DIRECTIONAL_MASKS",
		"PositionalMaskConfiguration" : "NUM_POSITIONAL_MASKS",
		"VertexColorMaskConfiguration" : "NUM_VERTEX_COLOR_MASKS",
		"UVMapConfiguration" : "NUM_UV_MAPS",
		"UVTransformConfiguration" : "NUM_UV_TRANSFORMS",
		"TriplanarUVConfiguration" : "NUM_TRIPLANAR_MAPS",
		"Texture" : "NUM_TEXTURES",
		"IntValue" : "NUM_INT_VALUES",
		"FloatValue" : "NUM_FLOAT_VALUES",
		"Vector2Value" : "NUM_VECTOR2_VALUES",
		"Vector3Value" : "NUM_VECTOR3_VALUES",
		"Vector4Value" : "NUM_VECTOR4_VALUES"
	}
	
	print(mapped_resources)
	
	edited_composite_material.shader.code = material.shader.code.replace("NUM_LAYERS 1", "NUM_LAYERS " + str(material.layers.size()))
	
	for key in definition_map.keys():
		material.shader.code = material.shader.code.replace(definition_map[key] + " 0", definition_map[key] + " " + str(mapped_resources[key].size()))
	
	if mapped_resources.Texture.size() > 0:
		var _arr = []
		_arr.resize(mapped_resources.Texture.size())
		_arr.fill(null)
		edited_composite_material.set_shader_parameter("textures", _arr)
	
	for key in mapped_resources.keys():
		var _idx : int = 0
		for resource : Resource in mapped_resources[key]:
			if resource.has_signal("value_changed"):
				if !resource.has_connections("value_changed"):
					resource.connect("value_changed", set_shader_property.bind(_idx))
				
			#initialize export values
			for property in resource.get_property_list():
				#print(property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE or (property.hint & PROPERTY_HINT_RESOURCE_TYPE and property.hint_string == "Texture2D"))
				if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE or (property.hint & PROPERTY_HINT_RESOURCE_TYPE and property.hint_string == "Texture2D"):
					#call setter on value so that set_shader_property automatically gets called correctly
					print("setting ", property.name, " to ", resource.get(property.name))
					resource.set(property.name, resource.get(property.name))
				
			_idx += 1
	
	var fragment_code : String = ""
	var get_layer_albedo_string : String = "switch (layer_index) {"
	var get_layer_normal_string : String = "switch (layer_index) {"
	var get_layer_roughness_string : String = "switch (layer_index) {"
	var get_layer_metallic_string : String = "switch (layer_index) {"
	
	#Sorry for the very funky string formatting up ahead! It's all to have nicely formatted shader code
	
	var _idx : int = 0
	for layer : CompositeMaterialLayer in material.layers:
		fragment_code +=\
	"layer_masks[%s] = %s;
	if (layer_masks[%s] >= 0.995) starting_index = %s;\n" % [_idx, layer.mask.get_expression(), _idx, _idx]
	
		get_layer_albedo_string += "
		case %s:
			return %s;" % [_idx, layer.albedo.get_expression()]
		
		get_layer_normal_string += "
		case %s:
			return %s;" % [_idx, layer.normal.get_expression()]
		
		get_layer_roughness_string += "
		case %s:
			return %s;" % [_idx, layer.roughness_value.get_expression()]
		
		get_layer_metallic_string += "
		case %s:
			return %s;" % [_idx, layer.metallic_value.get_expression()]
		
		_idx += 1
	
	get_layer_albedo_string += "
	}"
	get_layer_normal_string += "
	}"
	get_layer_roughness_string += "
	}"
	get_layer_metallic_string += "
	}"
	
	material.shader.code = material.shader.code.replace("//get_albedo", get_layer_albedo_string)
	material.shader.code = material.shader.code.replace("//get_normal", get_layer_normal_string)
	material.shader.code = material.shader.code.replace("//get_roughness", get_layer_roughness_string)
	material.shader.code = material.shader.code.replace("//get_metallic", get_layer_metallic_string)
	
	material.shader.code = material.shader.code.replace("//fragment", fragment_code)
	

func set_shader_property(value : Variant, shader_property_name : String, id : int) -> void:
	edited_composite_material.get_property_list() #????? This line needs to be present or get_shader_parameter will return Nil
	
	var _current_value : Array = edited_composite_material.get_shader_parameter(shader_property_name)
	_current_value[id] = value
	edited_composite_material.set_shader_parameter(shader_property_name, _current_value)

func edit_material(material : CompositeMaterial) -> void:
	edited_composite_material = material

	output_node.represented_composite_material = edited_composite_material

	reconstruct_material_graph(material)

func clear_graph() -> void:
	for child in get_children():
		if child is PopupMenu or child == output_node or child.name == "_connection_layer": #_connection_layer is an internal child made by GraphEdit itself to render connection lines. Removing it freezes the GraphEdit. See editor/scene/GraphEdit.cpp:3190 and editor/scene/GraphEdit.cpp:745 for more info
			continue 
		
		child.queue_free()

func reconstruct_material_graph(material : CompositeMaterial) -> void:
	
	print("reconstructing material ", material.layers)
	
	clear_graph()
	
	var nodes_to_add : Dictionary[Resource, Dictionary] = {} #Map of what resources to add and which nodes and ports they should connect to
	var existing_resources : Dictionary[CPMB_Base, CompositeMaterialBuilderGraphNode] = {} #Map of which resources have already been manifested as nodes
	var decomposition_nodes : Dictionary[CPMB_Base, CompositeMaterialBuilderGraphNode] = {} #Map of decomposition nodes keyed by their source value resource
	
	for layer in material.layers:
		print("layer")
		nodes_to_add[layer] = {"from_port": 0, "to_node": "output", "to_port": 0}
	
	while nodes_to_add.keys().size() > 0:
		var _do_not_connect_automatically : bool = false
		var _resource : Resource = nodes_to_add.keys()[0]
		var _instructions : Dictionary = nodes_to_add[_resource]
		var _to_node = get_node(_instructions.to_node)
		
		var _new_node : CompositeMaterialBuilderGraphNode
		if _resource is CompositeMaterialLayer:
			_new_node = preload("res://addons/CompositeMaterial/builder/GraphNodes/UserNodes/LayerNode.tscn").instantiate()
			add_child(_new_node)
			
			#fix connections with output node
			var _new_subnode = _to_node.add_slot()
			_new_subnode.linked_node = _new_node
			connect_node(_new_node.name, 0, _new_subnode.name, 0)
			_do_not_connect_automatically = true
			
			nodes_to_add[_resource.albedo] = {"to_node": String(_new_node.name), "to_port": 0, "from_port": _resource.albedo.get_output_port_for_state()}
			#nodes_to_add[_resource.normal] = {"to_node": _new_node.name, "to_port": 1, "from_port": _resource.albedo.get_output_port_for_state()}
		
		if _resource is CPMB_TextureConfiguration:
			_new_node = preload("res://addons/CompositeMaterial/builder/GraphNodes/UserNodes/TextureNode.tscn").instantiate()
			add_child(_new_node)
		
		
		if _new_node:
			_new_node.position_offset = Vector2(0, 0)
			_new_node.set_represented_object(_resource)
			if !_do_not_connect_automatically:
				connect_node(_new_node.name, _instructions.from_port, _instructions.to_node, _instructions.to_port)
		
		nodes_to_add.erase(_resource)
	
	output_node.large_offset = true
	arrange_nodes()
	output_node.set_deferred("large_offset", false)
