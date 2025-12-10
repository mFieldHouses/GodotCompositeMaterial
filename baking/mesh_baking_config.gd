extends Resource
class_name MeshBakingConfig

##Config for a singular mesh in a model to be baked

var paste_immune_properties : Array = ["done_baking", "albedo_tex_path", "roughness_tex_path", "metallic_tex_path", "normal_tex_path", "source_mesh_name", "supported", "enabled", "RefCounted", "Resource", "resource_local_to_scene", "resource_path", "resource_name", "resource_scene_unique_id", "script", "mesh_baking_config.gd", "paste_immune_properties"]

@export var supported : bool = true #Determines whether the mesh is bakeable

@export var enabled : bool = true

@export var source_mesh_name : String = ""
@export var output_name : String = ""

@export var output_path : String = ""

@export var resolution_x : int = 512
@export var resolution_y : int = 512

@export var bake_albedo : bool = true
@export var bake_metallic : bool = true
@export var bake_roughness : bool = true
@export var bake_normal : bool = true
@export var enable_alpha : bool = false

@export var bake_onto_self : bool = true
@export var bake_onto_other : bool = false

@export var done_baking : bool = false
@export var albedo_tex_path : String = ""
@export var roughness_tex_path : String = ""
@export var metallic_tex_path : String = ""
@export var normal_tex_path : String = ""

func paste(new_config : MeshBakingConfig):
	for property in new_config.get_property_list():
		if property.name not in paste_immune_properties:
			set(property.name, new_config.get(property.name))
