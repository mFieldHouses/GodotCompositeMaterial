@tool
extends CompositeMaterialBuilderGraphNode
class_name LayerNode

var represented_layer : CompositeMaterialLayer

var capturing_keyboard : bool = false

func _node_ready() -> void:
	
	represented_layer = CompositeMaterialLayer.new()
	
	if Engine.is_editor_hint():
		node_selected.connect(edit_layer)
	
	represented_layer.roughness_value.value = 0.5
	represented_layer.metallic_value.value = 0.5
	
	$alpha_in/value.value_changed.connect(func(x): if represented_layer.alpha is CPMB_FloatValue: represented_layer.alpha.value = x)
	$roughness_in/value.value_changed.connect(func(x): if represented_layer.roughness_value is CPMB_FloatValue: represented_layer.roughness_value.value = x)
	$metallic_in/value.value_changed.connect(func(x): if represented_layer.metallic_value is CPMB_FloatValue: represented_layer.metallic_value.value = x)


func edit_layer() -> void:
	EditorInterface.edit_resource(represented_layer)
	

func enable_value(idx : int, state : bool = true) -> void:
	match idx:
		0:
			$alpha_in/value.editable = state
		1:
			$roughness_in/value.editable = state
		2:
			$metallic_in/value.editable = state
			
func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	#print("before setting the alpha, it was ", represented_layer.alpha)
	#print("layernode: connect and pass object ", object, " on port ", input_port_id)
	match input_port_id:
		0:
			represented_layer.albedo = object
		1:
			#print("before setting the alpha, it was ", represented_layer.alpha)
			represented_layer.alpha = object
			enable_value(0, false)
			#print('set layer alpha, it is now ', represented_layer.alpha)
		2:
			represented_layer.normal = object
		3:
			represented_layer.roughness_value = object
			enable_value(1, false)
		4:
			represented_layer.metallic_value = object
			enable_value(2, false)
		5:
			represented_layer.occlusion = object
		6:
			represented_layer.mask = object

func disconnected(input_port_id : int) -> void:
	get(represented_resource_variable_name).initialise_value(input_port_id)
	
	match input_port_id:
		1:
			enable_value(0, true)
			represented_layer.alpha.value = $alpha_in/value.value
		3:
			enable_value(1, true)
			represented_layer.metallic_value.value = $metallic_in/value.value
		4:
			enable_value(2, true)
			represented_layer.roughness_value.value = $roughness_in/value.value

func get_represented_object(port_idx : int) -> Object:
	return represented_layer

func set_represented_object(object : Object) -> void:
	#print("represented layer got set to ", object)
	#print("alpha is currently ", object.alpha)
	represented_layer = object
	if represented_layer.alpha.internal_to_node:
		$alpha_in/value.value = represented_layer.alpha.value
	if represented_layer.roughness_value.internal_to_node:
		$roughness_in/value.value = represented_layer.roughness_value.value
	if represented_layer.metallic_value.internal_to_node:
		$metallic_in/value.value = represented_layer.metallic_value.value
