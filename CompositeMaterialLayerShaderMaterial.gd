extends ShaderMaterial
class_name CompositeMaterialLayerShaderMaterial

var layer_config : CompositeMaterialLayer
var shaded = false
	
static func create(init_layer_config, init_is_shaded):
	var new_instance = CompositeMaterialLayerShaderMaterial.new()
	new_instance.layer_config = init_layer_config
	
	if init_is_shaded:
		new_instance.shaded = true
		new_instance.shader = load("res://addons/CompositeMaterial/shaders/CompositeMaterialLayerUnshaded.gdshader")
	else:
		new_instance.shaded = false
		new_instance.shader = load("res://addons/CompositeMaterial/shaders/CompositeMaterialLayerUnshaded.gdshader")
	
	return new_instance

func update_shaded(is_shaded):
	if is_shaded != shaded:
		if is_shaded:
			shaded = true
			shader = load("res://addons/CompositeMaterial/shaders/CompositeMaterialLayerShaded.gdshader")
		else:
			shaded = false
			shader = load("res://addons/CompositeMaterial/shaders/CompositeMaterialLayerUnshaded.gdshader")

	
func update_config(new_config : CompositeMaterialLayer):
	print("update config")
	layer_config = new_config
	apply_config()


func apply_config():
	#print("apply config")
	for property in layer_config.get_property_list():
		if layer_config.get(property.name) != null:
			#print("setting shader property ", property.name, " to ", layer_config.get(property.name))
			set_shader_parameter(property.name, layer_config.get(property.name))
