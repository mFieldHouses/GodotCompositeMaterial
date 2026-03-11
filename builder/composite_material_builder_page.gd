@tool
extends GraphEdit
class_name CompositeMaterialBuilderPage

var output_node : CompositeMaterialOutputNode

var node_mappings : Array = [
	["LayerNode", "VariableNode", "", "", "", "DistanceFadeNode"],
	["textures/TextureNode", "textures/ColorRampNode", "textures/NormalMapNode", "textures/DepthMapNode", "textures/NoiseTextureNode"],
	["UVTransformNode","UVMapNode","TriplanarMapNode"],
	["masks/DirectionalMaskNode", "masks/PositionalMaskNode", "masks/VertexColorMaskNode", "masks/EffectShapeMaskNode", "masks/UVMaskNode", "masks/NormalMapMaskNode"],
	["utility/TimeNode", "utility/MathNode", "utility/VectorOperationNode"]
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

var initial_mouse_position : Vector2 #value used for storing where the user opened the context menu in case the user wants to add a node

var is_building_material : bool = false

func _ready() -> void:
	connection_request.connect(_connection_requested)
	disconnection_request.connect(_disconnection_request)
	
	node_selected.connect(func(node): selected_node = node)
	node_deselected.connect(func(node): selected_node = null)
	
	output_node = $output
	output_node.request_rebuild.connect(build_material)


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
	var _from_node : CompositeMaterialBuilderGraphNode = get_node(String(from_node))
	var _to_node : CompositeMaterialBuilderGraphNode = get_node(String(to_node))
	
	if _to_node is LayerNode:
		if to_port == 2:
			_to_node.enable_value(0, true)
		elif to_port == 3:
			_to_node.enable_value(1, true)
	
	disconnect_node(from_node, from_port, to_node, to_port)
	
	_to_node.disconnected(to_port)
	
	build_material()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.pressed:
			return
		
		if event.button_index == MOUSE_BUTTON_RIGHT:
			initial_mouse_position = get_local_mouse_position()
			$context_menu.popup(Rect2i(get_global_mouse_position() + Vector2(0, 50), Vector2i(100,100)))
	
	elif event is InputEventKey:
		if event.keycode == KEY_DELETE or event.keycode == KEY_BACKSPACE and event.pressed:
			if selected_node is not CompositeMaterialOutputNode:
				selected_node.queue_free()
				selected_node = null
			

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
	
	_node.position_offset = (scroll_offset / zoom) + (initial_mouse_position / zoom)

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
	
	is_building_material = true
	
	#Clear out material
	edited_composite_material.layers = [] as Array[CompositeMaterialLayer]
	
	#Map out all used resources
	var mapped_resources : Dictionary[String, Array] = {
		#"DirectionalMaskConfiguration": [],
		#"PositionalMaskConfiguration": [],
		#"VertexColorMaskConfiguration": [],
		#"EffectShapeMaskConfiguration": [],
		#
		#"UVTransformConfiguration": [],
		#"UVMapConfiguration": [],
		#"TriplanarUVConfiguration": [],
		#
		#"ColorRampConfiguration": [],
		#"ColorRampTexture": [], #need their own array for repeat_disable hint
		#"TextureConfiguration": [],
		#"Texture": [],
		#
		#"ComposeVector2": [],
		#"ComposeVector3": [],
		#"ComposeVector4": [],
		#
		#"DecomposeVector2": [],
		#"DecomposeVector3": [],
		#"DecomposeVector4": [],
		#
		#"IntValue": [],
		#"FloatValue": [],
		#"Vector2Value": [],
		#"Vector3Value": [],
		#"Vector4Value": []
	}
	
	var resources_to_check : Array[CPMB_Base] = []
	
	#Initialize resources_to_check with resources in all layers
	for subnode : SubNode in $output.get_connected_layers():
		var represented_layer : CompositeMaterialLayer = subnode.linked_node.represented_layer
		edited_composite_material.layers.append(represented_layer)
		
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
		var resource_to_check : CPMB_Base = resources_to_check.pop_front()
		var resource_mapping_key : String = resource_to_check.get_mapping_key()
		print("mapping ", resource_to_check)
		
		if resource_mapping_key != "":
			if !mapped_resources.has(resource_mapping_key):
				mapped_resources[resource_mapping_key] = []
			
			if mapped_resources[resource_mapping_key].has(resource_to_check):
				continue
			
			resource_to_check.index = mapped_resources[resource_mapping_key].size()
			mapped_resources[resource_mapping_key].append(resource_to_check)
			
		resources_to_check.append_array(resource_to_check.get_child_resources())
		
		if !resource_to_check.is_connected("request_material_rebuild", request_rebuild_material):
			resource_to_check.request_material_rebuild.connect(request_rebuild_material)
		
		resource_to_check.on_mapped(mapped_resources)
	
	var _shader : Shader = Shader.new()
	edited_composite_material.shader = _shader
	_shader.code = preload("res://addons/CompositeMaterial/shaders/CompositeMaterialBase.gdshader").code
	
	var definition_map : Dictionary[String, String] = {
		"DirectionalMaskConfiguration" : "NUM_DIRECTIONAL_MASKS",
		"PositionalMaskConfiguration" : "NUM_POSITIONAL_MASKS",
		"VertexColorMaskConfiguration" : "NUM_VERTEX_COLOR_MASKS",
		"EffectShapeMaskConfiguration" : "NUM_EFFECT_SHAPE_MASKS",
		"UVMapConfiguration" : "NUM_UV_MAPS",
		"UVTransformConfiguration" : "NUM_UV_TRANSFORMS",
		"TriplanarUVConfiguration" : "NUM_TRIPLANAR_MAPS",
		"ColorRampTexture": "NUM_COLOR_RAMPS",
		"Texture" : "NUM_TEXTURES",
		"NormalMapTexture" : "NUM_NORMAL_MAP_TEXTURES",
		"IntValue" : "NUM_INT_VALUES",
		"FloatValue" : "NUM_FLOAT_VALUES",
		"DecomposeVector2" : "NUM_VECTOR2_DECOMPOSITIONS",
		"DecomposeVector3" : "NUM_VECTOR3_DECOMPOSITIONS",
		"DecomposeVector4" : "NUM_VECTOR4_DECOMPOSITIONS",
		"Vector2Value" : "NUM_VECTOR2_VALUES",
		"Vector3Value" : "NUM_VECTOR3_VALUES",
		"Vector4Value" : "NUM_VECTOR4_VALUES"
	}
	
	#print(mapped_resources)
	
	edited_composite_material.shader.code = edited_composite_material.shader.code.replace("NUM_LAYERS 1", "NUM_LAYERS " + str(edited_composite_material.layers.size()))
	
	var parameters_to_be_initialised : Array
	
	for key in definition_map.keys():
		
		if !mapped_resources.has(key):
			continue
		if mapped_resources[key].size() == 0:
			continue
		
		print(definition_map[key] + " " + str(mapped_resources[key].size()))

		
		edited_composite_material.shader.code = edited_composite_material.shader.code.replace(definition_map[key] + " 0", definition_map[key] + " " + str(mapped_resources[key].size()))
		
		var _iter : int = 0
		var _last_idx : int = 0
		var _found_all_parameters : bool = false
		while _found_all_parameters == false:
			#print("high loop")
			var _idx : int = edited_composite_material.shader.code.find("[" + definition_map[key] + "]", _last_idx)
			if _idx == -1:
				_found_all_parameters = true
				break
			
			var _offset : int = 0
			var _found_parameter_name : bool = false
			
			var _found_parameter_name_start : bool = false
			var _parameter_name_start : int = 0
			
			var _found_parameter_name_end : bool = false
			var _parameter_name_end : int = 0
			
			while _found_parameter_name == false:
				#print("low loop")
				
				if !_found_parameter_name_start:
					if edited_composite_material.shader.code[_idx + _offset] == " ":
						_parameter_name_start = _idx + _offset + 1
						_found_parameter_name_start = true
				else:
					if _found_parameter_name_end:
						_found_parameter_name = true
						break
					
					if edited_composite_material.shader.code[_idx + _offset] == ";" or edited_composite_material.shader.code[_idx + _offset] == " ":
						_parameter_name_end = _idx + _offset
						_found_parameter_name_end = true
					
				_offset += 1
			
		#	print("from ", _parameter_name_start, " to ", _parameter_name_end, ": ", edited_composite_material.shader.code.substr(_parameter_name_start, _parameter_name_end - _parameter_name_start))
			parameters_to_be_initialised.append(edited_composite_material.shader.code.substr(_parameter_name_start, _parameter_name_end - _parameter_name_start))
			_last_idx = _idx + 1
			_iter += 1
			
		#edited_composite_material.shader.code = edited_composite_material.shader.code.replace("[" + definition_map[key] + "]", "[" + str(mapped_resources[key].size()) + "]")
	
	#make sure the editor notices the shader update
	edited_composite_material.shader = null
	edited_composite_material.shader = _shader
	
	#print(mapped_resources.FloatValue.size())
	
	for parameter_name in parameters_to_be_initialised:
		print("initialising ", parameter_name)
		edited_composite_material.set_shader_parameter(parameter_name, null)
	
	if mapped_resources.has("Texture"):
		if mapped_resources.Texture.size() > 0:
			var _arr = []
			_arr.resize(mapped_resources.Texture.size())
			_arr.fill(null)
			edited_composite_material.set_shader_parameter("textures", _arr)
	
	if mapped_resources.has("NormalMapTexture"):
		if mapped_resources.Texture.size() > 0:
			var _arr = []
			_arr.resize(mapped_resources.Texture.size())
			_arr.fill(null)
			edited_composite_material.set_shader_parameter("normal_map_textures", _arr)
	
	if mapped_resources.has("ColorRampTexture"):
		if mapped_resources.ColorRampTexture.size() > 0:
			var _arr = []
			_arr.resize(mapped_resources.ColorRampTexture.size())
			_arr.fill(null)
			edited_composite_material.set_shader_parameter("color_ramp_textures", _arr)
	
	for key in mapped_resources.keys():
		var _idx : int = 0
		for resource : Resource in mapped_resources[key]:
			if resource == null:
				printerr("resource is null")
				continue
			
			if resource.has_signal("value_changed"):
				if resource.has_connections("value_changed"):
					resource.disconnect("value_changed", set_shader_property)
				#print("connecting resource ", resource, " to index ", _idx)
				resource.connect("value_changed", set_shader_property.bind(_idx))
				
			
			for property in resource.get_property_list():
				if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE or (property.hint & PROPERTY_HINT_RESOURCE_TYPE and property.hint_string == "Texture2D"):
					
					#just set the value to what it was so that value_changed gets called on that resource
					resource.set(property.name, resource.get(property.name))
				
			_idx += 1
	
	var fragment_code : String = ""
	var get_layer_albedo_string : String = "switch (layer_index) {"
	var get_layer_normal_string : String = "switch (layer_index) {"
	var get_layer_roughness_string : String = "switch (layer_index) {"
	var get_layer_metallic_string : String = "switch (layer_index) {"
	
	#Sorry for the funky string formatting up ahead! It's all to have nicely formatted shader code
	
	var _idx : int = 0
	for layer : CompositeMaterialLayer in edited_composite_material.layers:
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
	
	var get_color_ramp_string : String = "switch (color_ramp_id) {"
	
	if mapped_resources.has("ColorRampConfiguration"):
		_idx = 0
		for color_ramp_config : CPMB_ColorRampConfiguration in mapped_resources.ColorRampConfiguration:
			get_color_ramp_string += "
			case %s:
				return texture(color_ramp_textures[%s], vec2(fac, 0.0));" % [_idx, mapped_resources.ColorRampTexture.find(color_ramp_config.gradient_texture)]
			_idx += 1
		
	get_color_ramp_string += "
	}"
	
	_shader.code = _shader.code.replace("//get_albedo", get_layer_albedo_string)
	_shader.code = _shader.code.replace("//get_normal", get_layer_normal_string)
	_shader.code = _shader.code.replace("//get_roughness", get_layer_roughness_string)
	_shader.code = _shader.code.replace("//get_metallic", get_layer_metallic_string)
	
	_shader.code = _shader.code.replace("//get_color_ramp", get_color_ramp_string)
	
	_shader.code = _shader.code.replace("//fragment", fragment_code)
	
	#make sure the editor notices the shader update
	edited_composite_material.shader = null
	edited_composite_material.shader = _shader
	
	is_building_material = false
	

func request_rebuild_material() -> void:
	if !is_building_material:
		build_material()

func set_shader_property(value : Variant, shader_property_name : String, id : int) -> void:
	edited_composite_material.get_property_list() #????? This line needs to be present or get_shader_parameter will return Nil
	
	#print("setting ", shader_property_name, " for index ", id)
	
	var _current_value : Array = edited_composite_material.get_shader_parameter(shader_property_name)
	#print("Current value: ", _current_value, " id: ", id)
	_current_value[id] = value
	edited_composite_material.set_shader_parameter(shader_property_name, _current_value)

func edit_material(material : CompositeMaterial) -> void:
	edited_composite_material = material
	
	output_node.represented_composite_material = material
	
	reconstruct_material_graph(edited_composite_material)

func clear_graph() -> void:
	for child in get_children():
		if child is PopupMenu or child == output_node or child.name == "_connection_layer": #_connection_layer is a semi-internal child made by GraphEdit itself to render connection lines. Removing it freezes the GraphEdit. See editor/scene/GraphEdit.cpp:3190 and editor/scene/GraphEdit.cpp:745 for more info
			continue 
		
		child.queue_free()

func instantiate_node(node_id : String) -> GraphNode:
	return load("res://addons/CompositeMaterial/builder/GraphNodes/UserNodes/" + node_id + ".tscn").instantiate()

func reconstruct_material_graph(material : CompositeMaterial) -> void:
	
	print("reconstructing material ", material.layers)
	
	clear_graph()
	
	var nodes_to_add : Array[Array] = [] #Map of what resources to add and which nodes and ports they should connect to
	var existing_resources : Dictionary[CPMB_Base, CompositeMaterialBuilderGraphNode] = {} #Map of which resources have already been manifested as nodes
	var decomposition_nodes : Dictionary[CPMB_Base, CompositeMaterialBuilderGraphNode] = {} #Map of decomposition nodes keyed by their source value resource
	
	var layer_nodes : Array[LayerNode] = []

	for layer in material.layers:
		nodes_to_add.append([layer, {"from_port": 0, "to_node": "output", "to_port": 0}])
	
	while nodes_to_add.size() > 0:
		var _tmp = nodes_to_add.pop_front()
		var _resource : Resource = _tmp[0]
		var _instructions : Dictionary = _tmp[1]
		print("to node: ", _instructions.to_node)
		var _to_node = get_node(String(_instructions.to_node))
		
		print("resource ", _resource)
		
		if _resource is CPMB_Base:
			if _resource.internal_to_node:
				print("resource is internal, skipping this one")
				continue
		
		var _new_node : CompositeMaterialBuilderGraphNode
		
		if existing_resources.has(_resource as CPMB_Base):
			print("resource already exists as a node")
			_new_node = existing_resources[_resource as CPMB_Base]
		
		if _resource is CompositeMaterialLayer:
			_new_node = instantiate_node("LayerNode")
			add_child(_new_node)
			
			#fix connections with output node
			var _new_subnode = _to_node.add_slot()
			_new_subnode.linked_node = _new_node
			connect_node(_new_node.name, 0, _new_subnode.name, 0)
			
			nodes_to_add.append([_resource.albedo, {"to_node": String(_new_node.name), "to_port": 0, "from_port": _resource.albedo.get_output_port_for_state()}])
			nodes_to_add.append([_resource.normal, {"to_node": _new_node.name, "to_port": 1, "from_port": _resource.normal.get_output_port_for_state()}])
			nodes_to_add.append([_resource.roughness_value, {"to_node": String(_new_node.name), "to_port": 2, "from_port": _resource.roughness_value.get_output_port_for_state()}])
			nodes_to_add.append([_resource.metallic_value, {"to_node": String(_new_node.name), "to_port": 3, "from_port": _resource.metallic_value.get_output_port_for_state()}])
			nodes_to_add.append([_resource.mask, {"to_node": String(_new_node.name), "to_port": 4, "from_port": _resource.albedo.get_output_port_for_state()}])
			
			layer_nodes.append(_new_node)
			
			#await get_tree().create_timer(0.1).timeout
			_new_node.set_represented_object(_resource)
			continue
		
		else:
			_new_node = instantiate_node(_resource.get_node_name())
			var _input_port_resources = _resource.get_input_port_resources()
			for resource_to_add in _input_port_resources.keys():
				nodes_to_add.append([resource_to_add, {"to_node": String(_new_node.name), "to_port": _input_port_resources[resource_to_add], "from_port": resource_to_add.get_output_port_for_state()}])
		
		if _new_node:
			if !existing_resources.has(_resource):
				add_child(_new_node)
			connect_node(_new_node.name, _instructions.from_port, _instructions.to_node, _instructions.to_port)
			_to_node.call_deferred("connect_and_pass_object", _instructions.to_port, _resource)
			
			#await get_tree().create_timer(0.1).timeout
			_new_node.set_represented_object(_resource)
			existing_resources[_resource as CPMB_Base] = _new_node
	
	await get_tree().create_timer(0.1).timeout
	
	arrange_nodes()
	
	#manual final arrangements, because arrange_nodes() tends to arrange nodes very vertically
	output_node.position_offset.y = (layer_nodes[0].position_offset.y + layer_nodes.back().position_offset.y) / 2.0
	output_node.position_offset.x = layer_nodes[0].position_offset.x + 350
	
	scroll_offset = (layer_nodes[0].position_offset + layer_nodes.back().position_offset) / 2.0
