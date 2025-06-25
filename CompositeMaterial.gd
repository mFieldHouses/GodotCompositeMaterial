@tool
extends ShaderMaterial
class_name CompositeMaterial

@export var layers : Array[CompositeMaterialLayer]:
	set(x):
		layers = x
		build_material()

var material_instances : Array[CompositeMaterialLayerShaderMaterial]

#@export var base_albedo : Texture2D
#@export var base_normal_map : Texture2D
#@export_enum("Single Map", "Seperate Maps") var orm_mode : int = 0
#@export var base_orm_map : Texture2D
#@export var base_occlusion_map : Texture2D
#@export var base_roughness_map : Texture2D
#@export var base_metallic_map : Texture2D


func _init() -> void:
	shader = load("res://addons/CompositeMaterial/shaders/empty.gdshader")

func build_material() -> void:
	print("rebuild material")
	material_instances = []
	
	var idx : int = 0
	var previous_material : CompositeMaterialLayerShaderMaterial
	for layer_config in layers:
		if layer_config != null:
			var is_top_layer = (layers.back() == layer_config)
			var new_material = CompositeMaterialLayerShaderMaterial.create(layer_config, is_top_layer)
			
			if previous_material:
				previous_material.next_pass = new_material
			else:
				next_pass = new_material
			
			new_material.render_priority = idx + 1
			
			material_instances.append(new_material)
			if !layer_config.is_connected("changed", update_layer_configuration):
				layer_config.changed.connect(update_layer_configuration.bind(idx))
			update_layer_configuration(idx)
			previous_material = new_material
			idx += 1
	
	emit_changed()

func update_layer_configuration(layer_index : int):
	material_instances[layer_index].update_config(layers[layer_index])
