@tool
extends ShaderMaterial
class_name CompositeMaterial

@export var layers : Array[CompositeMaterialLayer]

@export_group("Base")
@export var base_albedo : Texture2D
@export var base_normal_map : Texture2D
@export_enum("Single Map", "Seperate Maps") var orm_mode : int = 0
@export var base_orm_map : Texture2D
@export var base_occlusion_map : Texture2D
@export var base_roughness_map : Texture2D
@export var base_metallic_map : Texture2D


func _init() -> void:
	shader = load("res://addons/CompositeMaterial/CompositeMaterial.gdshader")
	for i in shader.get_shader_uniform_list():
		print(i.name)
