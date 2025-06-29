extends ShaderMaterial
class_name CompositeMaterialLayerShaderMaterial

var layer_configs
	
enum layer_index {LAYER_A = 0, LAYER_B = 1, LAYER_C = 2}

static func create(init_layer_configs, enable_alpha):
	var new_instance = CompositeMaterialLayerShaderMaterial.new()
	new_instance.layer_configs = init_layer_configs
	
	if enable_alpha:
		new_instance.shader = load("res://addons/CompositeMaterial/shaders/CompositeMaterialUnitAE.gdshader")
	else:
		new_instance.shader = load("res://addons/CompositeMaterial/shaders/CompositeMaterialUnitAD.gdshader")
	
	return new_instance

func update_config(new_config : CompositeMaterialLayer, layer_idx : layer_index):
	print("update config")
	layer_configs[layer_idx] = new_config
	for property in new_config.get_property_list():
		if layer_configs[layer_idx].get(property.name) != null:
			set_shader_parameter(get_layer_prefix(layer_idx) + property.name, layer_configs[layer_idx].get(property.name))
			#print("setting shader property ", get_layer_prefix(layer_idx) + property.name)

func get_layer_prefix(layer_idx : layer_index) -> String:
	match layer_idx:
		layer_index.LAYER_A:
			return "layer_A_"
		layer_index.LAYER_B:
			return "layer_B_"
		layer_index.LAYER_C:
			return "layer_C_"
		_:
			return ""
