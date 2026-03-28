@tool
extends GraphEdit
class_name CompositeMaterialBuilderPage

const DEBUG_LEVEL : int = 1

signal material_rebuilt

var parent_dock : CompositeMaterialBuilderDock

var output_node : CompositeMaterialOutputNode

var node_mappings : Array = [
	["LayerNode", "ValueNode", "", "", "", "DistanceFadeNode"],
	["textures/TextureNode", "textures/NoiseTextureNode", "textures/NormalMapNode"],
	["convert/ColorRampNode", "convert/HSVTransformNode"],
	["UVTransformNode","UVMapNode","TriplanarMapNode"],
	["masks/DirectionalMaskNode", "masks/PositionalMaskNode", "masks/VertexColorMaskNode", "masks/EffectShapeMaskNode", "masks/UVMaskNode", "masks/NormalMapMaskNode"],
	["utility/TimeNode", "utility/MathNode", "utility/VectorOperationNode"]
]

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

@onready var editor_ur : EditorUndoRedoManager = EditorInterface.get_editor_undo_redo()

var capturing_keyboard : bool = false:
	set(x):
		#print('set capturing to ', x)
		capturing_keyboard = x
		if x == false:
			if edited_node:
				edited_node.stop_capturing_keyboard()
			edited_node = null
			
var edited_node : CompositeMaterialBuilderGraphNode


var is_building_material : bool = false
var auto_rebuild : bool = true

func _ready() -> void:
	connection_request.connect(_connection_requested)
	disconnection_request.connect(_disconnection_request)
	
	node_selected.connect(func(node): selected_node = node)
	node_deselected.connect(func(node): selected_node = null)
	
	output_node = $output
	output_node.request_rebuild.connect(build_material)
	output_node.output_node_position_changed.connect(func(): edited_composite_material.output_node_position = output_node.position_offset)
	
	var _menu : HBoxContainer = get_menu_hbox()
	var _appendix = preload("res://addons/CompositeMaterial/builder/toolbar_appendix.tscn").instantiate()
	_menu.add_child(_appendix)
	_appendix.set_auto_rebuild.connect(func(state: bool): auto_rebuild = state; print("set auto rebuild to ", state))
	_appendix.rebuild_manual.connect(build_material)
	
	
func _edit_title_request(node : CompositeMaterialBuilderGraphNode) -> void:
	print("request edit title from ", node)
	edited_node = node
	capturing_keyboard = true


func _stop_editing_title_request(node : CompositeMaterialBuilderGraphNode) -> void:
	print("request stop editing title from node, ", node)
	if node == edited_node:
		capturing_keyboard = false


func _connection_requested(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	print("request for connection: port ", from_port, " on ", from_node, " to port ", to_port, " on ", to_node)
	
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
		request_rebuild_material()
		return
	
	connect_node(from_node, from_port, to_node, to_port)
	_to_node.connect_and_pass_object(to_port, _from_node.get_represented_object(from_port))
	
	request_rebuild_material()


func _disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	print("disconnection request")
	var _from_node : CompositeMaterialBuilderGraphNode = get_node(String(from_node))
	var _to_node : CompositeMaterialBuilderGraphNode = get_node(String(to_node))
	
	disconnect_node(from_node, from_port, to_node, to_port)
	
	_to_node.disconnected(to_port)
	
	if _from_node.get(_from_node.represented_resource_variable_name).value_changed.is_connected(set_shader_property):
		_from_node.get(_from_node.represented_resource_variable_name).value_changed.disconnect(set_shader_property)
	
	request_rebuild_material()

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
				
				disconnect_all_from_node(selected_node)
				
				selected_node.queue_free()
				selected_node = null
				
				request_rebuild_material()
		
		if event.as_text_keycode() == "Ctrl+C":
			if selected_node:
				if selected_node is LayerNode:
					pass
				else:
					parent_dock.clipboard = selected_node.get(selected_node.represented_resource_variable_name)
		
		if event.as_text_keycode() == "Ctrl+V" and event.pressed:
			initial_mouse_position = get_local_mouse_position()
			add_node_from_resource(parent_dock.clipboard)
		
		if capturing_keyboard and edited_node:
			#print("capture key")
			#print("edited node is ", edited_node)
			#print('capturing keyboard is ', capturing_keyboard)
			if event.pressed:
				
				var _ignored_keys = [KEY_SHIFT, KEY_CTRL, KEY_TAB, KEY_CAPSLOCK]
				
				if event.keycode in _ignored_keys:
					return
				
				if event.keycode == KEY_ENTER:
					capturing_keyboard = false
				elif event.keycode == KEY_SPACE:
					edited_node.update_title(edited_node.title + " ")
				elif event.keycode == KEY_BACKSPACE:
					edited_node.update_title(edited_node.title.left(edited_node.title.length() - 1))
				else:
					if Input.is_key_pressed(KEY_SHIFT):
						edited_node.update_title(edited_node.title + event.as_text_key_label().trim_prefix("Shift+"))
					else:
						edited_node.update_title(edited_node.title + event.as_text_key_label().to_lower())
				

func disconnect_all_from_node(node : CompositeMaterialBuilderGraphNode) -> void:
	var _connections = get_connection_list_from_node(node.name)
	for _connection in _connections:
		disconnect_node(_connection.from_node, _connection.from_port, _connection.to_node, _connection.to_port)
	

func add_node(idx1 : int, idx2 : int) -> void:
	var _node_name = node_mappings[idx1][idx2]
	var _node = instantiate_node_at_mouse(_node_name)
	
	#editor_ur.create_action("Create Node")
	#editor_ur.add_do_property(self, "initial_mouse_position", initial_mouse_position)
	#editor_ur.add_do_method(self, "add_child", _node)
	#editor_ur.add_undo_method(_node, "queue_free")
	#editor_ur.commit_action()
	
	add_child(_node)
	
	#print()
	_node.request_disconnect_self.connect(disconnect_all_from_node.bind(_node))
	_node.request_edit_title.connect(_edit_title_request.bind(_node))
	_node.request_stop_editing_title.connect(_stop_editing_title_request.bind(_node))
	#material_rebuilt.connect(_node._material_rebuilt)
	

func add_node_from_resource(resource : Resource) -> void:
	var _new_node = instantiate_node_at_mouse(resource.get_node_name())
	add_child(_new_node)
	_new_node.set_represented_object(resource)


func instantiate_node_at_mouse(node_name : String) -> CompositeMaterialBuilderGraphNode:
	var _node = load("res://addons/CompositeMaterial/builder/GraphNodes/UserNodes/" + node_name + ".tscn").instantiate()
	
	_node.position_offset = (scroll_offset / zoom) + (initial_mouse_position / zoom)
	
	return _node

func build_material() -> void:
	
	print("build")
	
	is_building_material = true
	$rebuilding.visible = true
	
	await get_tree().create_timer(0.01).timeout
	
	#Clear out material
	edited_composite_material.layers = [] as Array[CompositeMaterialLayer]
	edited_composite_material.variable_resources = []
	
	#Map out all used resources
	var mapped_resources : Dictionary[String, Array] = {}
	
	var resources_to_check : Array[CPMB_Base] = []
	
	#Initialize resources_to_check with resources in all layers
	for subnode : SubNode in $output.get_connected_layers():
		var represented_layer : CompositeMaterialLayer = subnode.linked_node.represented_layer
		edited_composite_material.layers.append(represented_layer)
	
		resources_to_check.append_array(represented_layer.get_child_resources())
	
	
	#Go through resources_to_check and expand where neccesary until all resources have been checked and/or mapped.
	while resources_to_check.size() > 0:
		var resource_to_check : CPMB_Base = resources_to_check.pop_front()
		var resource_mapping_key : String = resource_to_check.get_mapping_key()
		debug_print("mapping " + str(resource_to_check), 0)
		
		
		if resource_to_check.is_variable and !edited_composite_material.variable_resources.has(resource_to_check):
			debug_print("added " + str(resource_to_check) + " to variables", 0)
			
			if resource_to_check.is_descendant_resource:
				edited_composite_material.variable_resources.append(resource_to_check.get_source_resource())
			else:
				edited_composite_material.variable_resources.append(resource_to_check)
		
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
		
		if resource_to_check.is_descendant_resource:
			if !resource_to_check.get_source_resource().is_connected("request_material_rebuild", request_rebuild_material):
				resource_to_check.get_source_resource().request_material_rebuild.connect(request_rebuild_material)
		
		
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
		"Vector4Value" : "NUM_VECTOR4_VALUES",
		"HSVTransformConfiguration": "NUM_HSV_TRANSFORMS"
	}
	
	#print(mapped_resources)
	
	edited_composite_material.shader.code = edited_composite_material.shader.code.replace("NUM_LAYERS 1", "NUM_LAYERS " + str(edited_composite_material.layers.size()))
	
	var parameters_to_be_initialised : Array
	
	for key in definition_map.keys():
		
		if !mapped_resources.has(key):
			continue
		if mapped_resources[key].size() == 0:
			continue
		
		debug_print(definition_map[key] + " " + str(mapped_resources[key].size()), 1)
		
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
		debug_print("initialising " + parameter_name, 1)
		edited_composite_material.set_shader_parameter(parameter_name, null)
	
	if mapped_resources.has("Texture"):
		if mapped_resources.Texture.size() > 0:
			var _arr = []
			_arr.resize(mapped_resources.Texture.size())
			_arr.fill(null)
			edited_composite_material.set_shader_parameter("linear_textures", _arr)
			edited_composite_material.set_shader_parameter("nearest_neighbor_textures", _arr)
	
	if mapped_resources.has("NormalMapTexture"):
		if mapped_resources.NormalMapTexture.size() > 0:
			var _arr = []
			_arr.resize(mapped_resources.NormalMapTexture.size())
			_arr.fill(null)
			edited_composite_material.set_shader_parameter("normal_map_textures", _arr)
	
	if mapped_resources.has("ColorRampTexture"):
		if mapped_resources.ColorRampTexture.size() > 0:
			var _arr = []
			_arr.resize(mapped_resources.ColorRampTexture.size())
			_arr.fill(null)
			edited_composite_material.set_shader_parameter("color_ramp_textures_linear", _arr)
			edited_composite_material.set_shader_parameter("color_ramp_textures_nearest", _arr)
	
	for key in mapped_resources.keys():
		var _idx : int = 0
		for resource : Resource in mapped_resources[key]:
			if resource == null:
				printerr("resource is null")
				continue
			
			if resource.has_signal("value_changed"):
				if resource.has_connections("value_changed"):
					resource.disconnect("value_changed", set_shader_property)
				debug_print("connecting resource " + str(resource) + " to index " + str(_idx), 1)
				resource.connect("value_changed", set_shader_property.bind(_idx))
				
			
			for property in resource.get_property_list():
				if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE or (property.hint & PROPERTY_HINT_RESOURCE_TYPE and property.hint_string == "Texture2D"):
					
					#just set the value to what it was so that value_changed gets called on that resource
					print("set ", property.name, " on ", resource)
					resource.set(property.name, resource.get(property.name))
				
			_idx += 1
	
	if mapped_resources.has("Texture"):
		edited_composite_material.set_shader_parameter("linear_textures", mapped_resources.Texture)
		edited_composite_material.set_shader_parameter("nearest_neighbor_textures", mapped_resources.Texture)
	
	if mapped_resources.has("ColorRampTexture"):
		edited_composite_material.set_shader_parameter("color_ramp_textures_linear", mapped_resources.ColorRampTexture)
		edited_composite_material.set_shader_parameter("color_ramp_textures_nearest", mapped_resources.ColorRampTexture)
	
	var fragment_code : String = ""
	
	var get_layer_albedo_string : String = "switch (layer_index) {"
	var get_layer_alpha_string : String = "switch (layer_index) {"
	var get_layer_normal_string : String = "switch (layer_index) {"
	var get_layer_roughness_string : String = "switch (layer_index) {"
	var get_layer_metallic_string : String = "switch (layer_index) {"
	var get_layer_occlusion_string : String = "switch (layer_index) {"
	
	#Sorry for the funky string formatting up ahead! It's all to have nicely formatted shader code
	
	var _idx : int = 0
	for layer : CompositeMaterialLayer in edited_composite_material.layers:
		fragment_code +=\
	"layer_masks[%s] = %s;
	if (layer_masks[%s] * get_layer_alpha(%s) >= 0.997) starting_index = %s;\n" % [_idx, layer.mask.get_expression(), _idx, _idx, _idx]
	
		get_layer_albedo_string += "
		case %s:
			return %s;" % [_idx, layer.albedo.get_expression()]
		
		get_layer_alpha_string += "
		case %s:
			return %s;" % [_idx, layer.alpha.get_expression()]
		
		get_layer_normal_string += "
		case %s:
			return %s;" % [_idx, layer.normal.get_expression()]
		
		get_layer_roughness_string += "
		case %s:
			return %s;" % [_idx, layer.roughness_value.get_expression()]
		
		get_layer_metallic_string += "
		case %s:
			return %s;" % [_idx, layer.metallic_value.get_expression()]
		
		get_layer_occlusion_string += "
		case %s:
			return %s;" % [_idx, "1.0 - (" + layer.occlusion.get_expression() + ")"]
		
		_idx += 1
	
	get_layer_albedo_string += "
	}"
	get_layer_alpha_string += "
	}"
	get_layer_normal_string += "
	}"
	get_layer_roughness_string += "
	}"
	get_layer_metallic_string += "
	}"
	get_layer_occlusion_string += "
	}"
	
	var get_color_ramp_string : String = "switch (color_ramp_id) {"
	
	if mapped_resources.has("ColorRampOutputConfiguration"):
		_idx = 0
		for color_ramp_config : CPMB_ColorRampOutputConfiguration in mapped_resources.ColorRampOutputConfiguration:
			
			var _uniform_name : String = ""
			if color_ramp_config.source_color_ramp_configuration.filter == 0:
				_uniform_name = "color_ramp_textures_linear"
			else:
				_uniform_name = "color_ramp_textures_nearest"
				
			get_color_ramp_string += "
			case %s:
				return texture(%s[%s], vec2(fac, 0.0));" % [_idx, _uniform_name, mapped_resources.ColorRampTexture.find(color_ramp_config.source_color_ramp_configuration.gradient_texture)]
			_idx += 1
		
	get_color_ramp_string += "
	}"
	
	_shader.code = _shader.code.replace("//get_albedo", get_layer_albedo_string)
	_shader.code = _shader.code.replace("//get_alpha", get_layer_alpha_string)
	_shader.code = _shader.code.replace("//get_normal", get_layer_normal_string)
	_shader.code = _shader.code.replace("//get_roughness", get_layer_roughness_string)
	_shader.code = _shader.code.replace("//get_metallic", get_layer_metallic_string)
	_shader.code = _shader.code.replace("//get_occlusion", get_layer_occlusion_string)
	
	_shader.code = _shader.code.replace("//get_color_ramp", get_color_ramp_string)
	
	_shader.code = _shader.code.replace("//fragment", fragment_code)
	
	#make sure the editor notices the shader update
	edited_composite_material.shader = null
	edited_composite_material.shader = _shader
	
	$rebuilding.visible = false
	is_building_material = false
	
	edited_composite_material.finish_building.emit()


func request_rebuild_material() -> void:
	debug_print("request received", 1)
	if !is_building_material and auto_rebuild:
		debug_print("rebuilding", 1)
		build_material()
	else:
		debug_print("not rebuilding", 1)

func set_shader_property(value : Variant, shader_property_name : String, id : int) -> void:
	edited_composite_material.get_property_list() #????? This line needs to be present or get_shader_parameter will return Nil
	
	debug_print("setting " + shader_property_name + " for index " + str(id), 1)
	
	var _current_value : Array = edited_composite_material.get_shader_parameter(shader_property_name)
	#print("Current value: ", _current_value, " id: ", id)
	_current_value[id] = value #ALERT: if you get an error here, it's likely you've forgot to set the value of a <X>Value-extending resource to INF
	edited_composite_material.set_shader_parameter(shader_property_name, _current_value)

func edit_material(material : CompositeMaterial) -> void:
	edited_composite_material = material
	
	output_node.represented_composite_material = material
	output_node.position_offset = edited_composite_material.output_node_position
	
	reconstruct_material_graph(edited_composite_material)

func clear_graph() -> void:
	for child in get_children():
		if child is PopupMenu or child == output_node or child.name == "_connection_layer": #_connection_layer is a semi-internal child made by GraphEdit itself to render connection lines. Removing it freezes the GraphEdit. See editor/scene/GraphEdit.cpp:3190 and editor/scene/GraphEdit.cpp:745 for more info
			continue 
		
		child.queue_free()

func instantiate_node(node_id : String) -> GraphNode:
	return load("res://addons/CompositeMaterial/builder/GraphNodes/UserNodes/" + node_id + ".tscn").instantiate()

func reconstruct_material_graph(material : CompositeMaterial) -> void:
	
	debug_print("reconstructing material " + str(material.layers), 0)
	is_building_material = true
	
	#clear_graph()
	
	var nodes_to_add : Array[Array] = [] #Map of what resources to add and which nodes and ports they should connect to
	var existing_resources : Dictionary[CPMB_Base, CompositeMaterialBuilderGraphNode] = {} #Map of which resources have already been manifested as nodes
	var identifiers : Dictionary[int, CompositeMaterialBuilderGraphNode] = {}
	var decomposition_nodes : Dictionary[CPMB_Base, CompositeMaterialBuilderGraphNode] = {} #Map of decomposition nodes keyed by their source value resource
	
	var layer_nodes : Array[LayerNode] = []

	for layer in material.layers:
		nodes_to_add.append([layer, {"from_port": 0, "to_node": "output", "to_port": 0}])
	
	while nodes_to_add.size() > 0:
		var _tmp = nodes_to_add.pop_front()
		var _resource : Resource = _tmp[0]
		var _instructions : Dictionary = _tmp[1]
		#print("to node: ", _instructions.to_node)
		var _to_node = get_node(String(_instructions.to_node))
		
		debug_print("==========================\nresource " + str(_resource), 0)
		
		if _resource is not CompositeMaterialLayer:
			if _resource.internal_to_node:
				debug_print("resource is internal, skipping this one", 1)
				continue
		
		var _new_node : CompositeMaterialBuilderGraphNode
		
		var _create_new_node : bool = true	
		if existing_resources.has(_resource as CPMB_Base):
			debug_print("resource already exists as a node", 1)
			_new_node = existing_resources[_resource as CPMB_Base]
			_create_new_node = false
		
		if _resource is CPMB_Base:
			if _resource.is_descendant_resource:
				debug_print("resource is a descendant resource", 1)
				var _source = _resource.get_source_resource()
				if existing_resources.has(_source):
					_new_node = existing_resources[_source]
					_create_new_node = false
		
		#if _resource is CPMB_ComposeVec2 or _resource is CPMB_ComposeVec3 or _resource is CPMB_ComposeVec4 or _resource is CPMB_DecomposeVec2 or _resource is CPMB_DecomposeVec3 or _resource is CPMB_DecomposeVec4 or _resource is CPMB_TextureOutputConfiguration:
			#if identifiers.has(_resource.source_identifier):
				#_new_node = identifiers[_resource.source_identifier]
				#_create_new_node = false
		
		elif _resource is CompositeMaterialLayer:
			debug_print("found layer resource", 1)
			_new_node = instantiate_node("LayerNode")
			add_child(_new_node)
			
			#fix connections with output node
			var _new_subnode = _to_node.add_slot()
			_new_subnode.linked_node = _new_node
			connect_node(_new_node.name, 0, _new_subnode.name, 0)
			
			nodes_to_add.append([_resource.albedo, {"to_node": String(_new_node.name), "to_port": 0, "from_port": _resource.albedo.get_output_port_for_state()}])
			nodes_to_add.append([_resource.alpha, {"to_node": _new_node.name, "to_port": 1, "from_port": _resource.alpha.get_output_port_for_state()}])
			nodes_to_add.append([_resource.normal, {"to_node": _new_node.name, "to_port": 2, "from_port": _resource.normal.get_output_port_for_state()}])
			nodes_to_add.append([_resource.roughness_value, {"to_node": String(_new_node.name), "to_port": 3, "from_port": _resource.roughness_value.get_output_port_for_state()}])
			nodes_to_add.append([_resource.metallic_value, {"to_node": String(_new_node.name), "to_port": 4, "from_port": _resource.metallic_value.get_output_port_for_state()}])
			nodes_to_add.append([_resource.occlusion, {"to_node": String(_new_node.name), "to_port": 5, "from_port": _resource.occlusion.get_output_port_for_state()}])
			nodes_to_add.append([_resource.mask, {"to_node": String(_new_node.name), "to_port": 6, "from_port": _resource.mask.get_output_port_for_state()}])
			
			layer_nodes.append(_new_node)
			
			_new_node.set_represented_object(_resource)
			_new_node.position_offset = _resource.node_position
			continue
		
		if _resource.get_node_name() != "" and _create_new_node:
			debug_print("Instantiating new node for this resource", 1)
			_new_node = instantiate_node(_resource.get_node_name())
		
		if _new_node:
			
			if !existing_resources.has(_resource):
				debug_print("Resource doesnt have a node yet, adding new node as child", 1)
				
				_new_node.request_edit_title.connect(_edit_title_request.bind(_new_node))
				_new_node.request_stop_editing_title.connect(_stop_editing_title_request.bind(_new_node))
				#material_rebuilt.connect(_new_node._material_rebuilt)
				
				add_child(_new_node)
			
			if _create_new_node:
				var _input_port_resources = _resource.get_input_port_resources()
				for resource_to_add in _input_port_resources.keys():
					debug_print("adding resource " + str(resource_to_add) + " to nodes_to_add", 2)
					nodes_to_add.append([resource_to_add, {"to_node": String(_new_node.name), "to_port": _input_port_resources[resource_to_add], "from_port": resource_to_add.get_output_port_for_state()}])
			
			debug_print("connecting node " + _new_node.name + " to " + str(_instructions.to_node), 2)
			_connection_requested.call_deferred(_new_node.name, _instructions.from_port, _instructions.to_node, _instructions.to_port)

			debug_print("setting represented_object on " + str(_new_node) + " with " + str(_resource), 2)
			_new_node.set_represented_object(_resource)
			
			if _resource.is_descendant_resource:
				existing_resources[_resource.get_source_resource()] = _new_node
				_new_node.position_offset = _resource.get_source_resource().node_position
			else:
				existing_resources[_resource as CPMB_Base] = _new_node
				_new_node.position_offset = _resource.node_position
			
	
	debug_print("finish setting up all resources", 1)
	
	await get_tree().create_timer(0.1).timeout
	
	scroll_offset = (layer_nodes[0].position_offset + layer_nodes.back().position_offset) / 2.0
	
	is_building_material = false
	
#func get_children_recursive(node : Node) -> Array[Node]:
	#var _result : Array[Node] = []
	#var _children_to_be_checked : Array[Node] = []
	#
	#for _child in node.get_children():
		#_children_to_be_checked.append(_child)
	#
	#while _children_to_be_checked.size() > 0:
		#var _child_to_check : Node = _children_to_be_checked[0]
		#for _subchild in _child_to_check.get_children():
			#_children_to_be_checked.append(_subchild)
		#
		#_result.append(_child_to_check)
		#_children_to_be_checked.erase(_child_to_check)
	#
	#return _result

func debug_print(message : String, debug_level : int = 0): ##A higher debug level is less important.
	if debug_level <= DEBUG_LEVEL:
		print(message)
