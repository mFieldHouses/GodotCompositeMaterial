@tool
extends GraphEdit
class_name CompositeMaterialBuilderPage

var output_node : CompositeMaterialOutputNode

var node_mappings : Array = [
	["VariableNode", "LayerNode", "TextureNode", "ColorRampNode", "", "", "", "DistanceFadeNode"],
	["UVTransformNode","UVMapNode","TriplanarMapNode"],
	["masks/DirectionalMaskNode", "masks/PositionalMaskNode", "masks/VertexColorMaskNode", "masks/EffectShapeMaskNode", "masks/UVMaskNode", "masks/NormalMapMaskNode"],
	["vector/VectorMathNode", "vector/ComposeVector2Node", "vector/DecomposeVector2Node", "vector/ComposeVector3Node", "vector/DecomposeVector3Node", "vector/ComposeVector4Node", "vector/DecomposeVector4Node"],
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

func _ready() -> void:
	connection_request.connect(_connection_requested)
	disconnection_request.connect(_disconnection_request)
	$context_menu.id_pressed.connect(_context_menu_option_pressed)
	
	node_selected.connect(func(node): selected_node = node)
	node_deselected.connect(func(node): selected_node = null)
	
	output_node = $output
	output_node.request_rebuild.connect(build_material)
	

func _process(delta: float) -> void:
	pass


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
		"EffectShapeMaskConfiguration": [],
		
		"UVTransformConfiguration": [],
		"UVMapConfiguration": [],
		"TriplanarUVConfiguration": [],
		
		"ColorRampConfiguration": [],
		"ColorRampTexture": [], #need their own array for repeat_disable hint
		"TextureConfiguration": [],
		"Texture": [],
		
		"ComposeVector2": [],
		"ComposeVector3": [],
		"ComposeVector4": [],
		
		"DecomposeVector2": [],
		"DecomposeVector3": [],
		"DecomposeVector4": [],
		
		"IntValue": [],
		"FloatValue": [],
		"Vector2Value": [],
		"Vector3Value": [],
		"Vector4Value": []
	}
	
	var resources_to_check : Array[CPMB_Base] = []
	
	var append_resource_to_mapped_resources : Callable = func(resource : CPMB_Base, array_name : String) -> void:
		#print("assigning index ", mapped_resources[array_name].size(), " to ", resource)
		resource.index = mapped_resources[array_name].size()
		mapped_resources[array_name].append(resource)
	
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
		print("mapping ", resource_to_check)
		
		if !resource_to_check.is_connected("request_material_rebuild", request_rebuild_material):
			resource_to_check.request_material_rebuild.connect(request_rebuild_material)
		
		if resource_to_check is CPMB_DirectionalMaskConfiguration:
			append_resource_to_mapped_resources.call(resource_to_check, "DirectionalMaskConfiguration")
		elif resource_to_check is CPMB_PositionalMaskConfiguration:
			append_resource_to_mapped_resources.call(resource_to_check, "PositionalMaskConfiguration")
		elif resource_to_check is CPMB_VertexColorMaskConfiguration:
			append_resource_to_mapped_resources.call(resource_to_check, "VertexColorMaskConfiguration")
		elif resource_to_check is CPMB_EffectShapeMaskConfiguration:
			append_resource_to_mapped_resources.call(resource_to_check, "EffectShapeMaskConfiguration")
		elif resource_to_check is CPMB_UVMapConfiguration:
			append_resource_to_mapped_resources.call(resource_to_check, "UVMapConfiguration")
		elif resource_to_check is CPMB_UVTransformConfiguration:
			append_resource_to_mapped_resources.call(resource_to_check, "UVTransformConfiguration")
			resources_to_check.append(resource_to_check.base_uv)
			resources_to_check.append(resource_to_check.offset)
			resources_to_check.append(resource_to_check.scale)
		elif resource_to_check is CPMB_TriplanarUVConfiguration:
			append_resource_to_mapped_resources.call(resource_to_check, "TriplanarUVConfiguration")
		elif resource_to_check is CPMB_UVConfiguration:
			printerr("Found a UVConfiguration, which should not happen")
		elif resource_to_check is CPMB_TextureConfiguration:
			append_resource_to_mapped_resources.call(resource_to_check, "TextureConfiguration")
			mapped_resources.Texture.append(resource_to_check.texture)
			resources_to_check.append(resource_to_check.uv)
		elif resource_to_check is CPMB_ColorRampConfiguration:
			mapped_resources.ColorRampTexture.append(resource_to_check.gradient_texture)
			append_resource_to_mapped_resources.call(resource_to_check, "ColorRampConfiguration")
			resources_to_check.append(resource_to_check.fac)
		
		elif resource_to_check is CPMB_Math:
			resources_to_check.append(resource_to_check.value_A)
			resources_to_check.append(resource_to_check.value_B)
		
		elif resource_to_check is CPMB_ComposeVec2:
			resources_to_check.append(resource_to_check.x)
			resources_to_check.append(resource_to_check.y)
			append_resource_to_mapped_resources.call(resource_to_check, "ComposeVector2")
		elif resource_to_check is CPMB_ComposeVec3:
			resources_to_check.append(resource_to_check.x)
			resources_to_check.append(resource_to_check.y)
			resources_to_check.append(resource_to_check.z)
			append_resource_to_mapped_resources.call(resource_to_check, "ComposeVector3")
		elif resource_to_check is CPMB_ComposeVec4:
			resources_to_check.append(resource_to_check.x)
			resources_to_check.append(resource_to_check.y)
			resources_to_check.append(resource_to_check.z)
			resources_to_check.append(resource_to_check.w)
			append_resource_to_mapped_resources.call(resource_to_check, "ComposeVector4")
		
		elif resource_to_check is CPMB_DecomposeVec2:
			resources_to_check.append(resource_to_check.source_vector)
			append_resource_to_mapped_resources.call(resource_to_check, "DecomposeVector2")
		elif resource_to_check is CPMB_DecomposeVec3:
			resources_to_check.append(resource_to_check.source_vector)
			append_resource_to_mapped_resources.call(resource_to_check, "DecomposeVector3")
		elif resource_to_check is CPMB_DecomposeVec4:
			resources_to_check.append(resource_to_check.source_vector)
			append_resource_to_mapped_resources.call(resource_to_check, "DecomposeVector4")
		
		elif resource_to_check is CPMB_TimeConfig:
			resources_to_check.append(resource_to_check.scale)
		
		#these are base classes, classes that extend these should be checked for first
		elif resource_to_check is CPMB_Vector2Value:
			print("Found vector2value")
			append_resource_to_mapped_resources.call(resource_to_check, "Vector2Value")
		elif resource_to_check is CPMB_Vector3Value:
			append_resource_to_mapped_resources.call(resource_to_check, "Vector3Value")
		elif resource_to_check is CPMB_Vector4Value:
			append_resource_to_mapped_resources.call(resource_to_check, "Vector4Value")
		elif resource_to_check is CPMB_IntValue:
			append_resource_to_mapped_resources.call(resource_to_check, "IntValue")
		elif resource_to_check is CPMB_FloatValue:
			#print("Resource is FloatValue: ", resource_to_check)
			append_resource_to_mapped_resources.call(resource_to_check, "FloatValue")
	
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
		print(definition_map[key] + " " + str(mapped_resources[key].size()))
		
		if mapped_resources[key].size() == 0:
			continue
		
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
	
	if mapped_resources.Texture.size() > 0:
		var _arr = []
		_arr.resize(mapped_resources.Texture.size())
		_arr.fill(null)
		edited_composite_material.set_shader_parameter("textures", _arr)
	
	if mapped_resources.ColorRampTexture.size() > 0:
		var _arr = []
		_arr.resize(mapped_resources.ColorRampTexture.size())
		_arr.fill(null)
		edited_composite_material.set_shader_parameter("color_ramp_textures", _arr)
	
	for key in mapped_resources.keys():
		var _idx : int = 0
		for resource : Resource in mapped_resources[key]:
			if resource == null:
				print("resource is null")
				continue #
			
			if resource.has_signal("value_changed"):
				if resource.has_connections("value_changed"):
					resource.disconnect("value_changed", set_shader_property)
				#print("connecting resource ", resource, " to index ", _idx)
				resource.connect("value_changed", set_shader_property.bind(_idx))
				
			
			for property in resource.get_property_list():
				if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE or (property.hint & PROPERTY_HINT_RESOURCE_TYPE and property.hint_string == "Texture2D"):
					#just set the value to what it was so that value_changed gets called on that resource
					
					#print("updating ", property.name, " on ", resource)
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
	

func request_rebuild_material() -> void:
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

	output_node.represented_composite_material = edited_composite_material

	reconstruct_material_graph(material)

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
	
	var nodes_to_add : Dictionary[Resource, Dictionary] = {} #Map of what resources to add and which nodes and ports they should connect to
	var existing_resources : Dictionary[CPMB_Base, CompositeMaterialBuilderGraphNode] = {} #Map of which resources have already been manifested as nodes
	var decomposition_nodes : Dictionary[CPMB_Base, CompositeMaterialBuilderGraphNode] = {} #Map of decomposition nodes keyed by their source value resource
	
	var layer_nodes : Array[LayerNode] = []
	
	for layer in material.layers:
		#print("layer")
		nodes_to_add[layer] = {"from_port": 0, "to_node": "output", "to_port": 0}
	
	while nodes_to_add.keys().size() > 0:
		var _do_not_connect_automatically : bool = false
		var _resource : Resource = nodes_to_add.keys()[0]
		var _instructions : Dictionary = nodes_to_add[_resource]
		var _to_node = get_node(_instructions.to_node)
		
		#print("resource ", _resource)
		
		nodes_to_add.erase(_resource)
		
		if _resource is CPMB_Base:
			if _resource.internal_to_node:
				continue
		
		var _new_node : CompositeMaterialBuilderGraphNode
		#print("checking resource type")
		if _resource is CompositeMaterialLayer:
			_new_node = instantiate_node("LayerNode")
			add_child(_new_node)
			
			#fix connections with output node
			var _new_subnode = _to_node.add_slot()
			_new_subnode.linked_node = _new_node
			connect_node(_new_node.name, 0, _new_subnode.name, 0)
			_do_not_connect_automatically = true
			
			nodes_to_add[_resource.albedo] = {"to_node": String(_new_node.name), "to_port": 0, "from_port": _resource.albedo.get_output_port_for_state()}
			#nodes_to_add[_resource.normal] = {"to_node": _new_node.name, "to_port": 1, "from_port": _resource.albedo.get_output_port_for_state()}
			nodes_to_add[_resource.mask] = {"to_node": String(_new_node.name), "to_port": 4, "from_port": _resource.mask.get_output_port_for_state()}
			
			_new_node.set_represented_object(_resource)
			layer_nodes.append(_new_node)
			continue
			#
		elif _resource is CPMB_DirectionalMaskConfiguration:
			_new_node = instantiate_node("masks/DirectionalMaskNode")
		elif _resource is CPMB_TextureConfiguration:
			_new_node = instantiate_node("TextureNode")
		
		
		
		if _new_node:
			add_child(_new_node)
			_new_node.set_represented_object(_resource)
			connect_node(_new_node.name, _instructions.from_port, _instructions.to_node, _instructions.to_port)
			(get_node(_instructions.to_node) as CompositeMaterialBuilderGraphNode).call_deferred("connect_and_pass_object", _instructions.to_port, _resource)
		
	
	await get_tree().create_timer(0.1).timeout
	
	arrange_nodes()
	
	#manual final arrangements, because arrange_nodes() tends to arrange nodes very vertically
	output_node.position_offset.y = (layer_nodes[0].position_offset.y + layer_nodes.back().position_offset.y) / 2.0
	output_node.position_offset.x = layer_nodes[0].position_offset.x + 350
	
	scroll_offset = (layer_nodes[0].position_offset + layer_nodes.back().position_offset) / 2.0
