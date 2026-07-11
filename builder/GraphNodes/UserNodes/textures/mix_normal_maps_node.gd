@tool
extends CompositeMaterialBuilderGraphNode
class_name MixNormalMapsNode

var represented_mix_normal_maps_config : CPMB_MixNormalMapsConfiguration

func _node_ready() -> void:
	$factor.value_changed.connect(func(x): represented_mix_normal_maps_config.factor = x)
	
	represented_mix_normal_maps_config = CPMB_MixNormalMapsConfiguration.new()
	
	if Engine.is_editor_hint():
		node_selected.connect(edit_self)

func edit_self() -> void:
	EditorInterface.edit_resource(represented_mix_normal_maps_config)

func get_represented_object(port_idx : int) -> Object:
	return represented_mix_normal_maps_config

func set_represented_object(object : Object) -> void:
	represented_mix_normal_maps_config = object
	$factor.value = object.scale

func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	match input_port_id:
		0:
			represented_mix_normal_maps_config.normal_map_A = object
		1:
			represented_mix_normal_maps_config.normal_map_B = object

func disconnected(input_port_id : int) -> void:
	represented_mix_normal_maps_config.initialise_value(input_port_id)
