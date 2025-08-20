extends Resource
class_name MeshBakingConfig

var paste_immune_properties : Array = ["source_mesh_name", "output_name"]

var supported : bool = true #Determines whether the mesh is bakeable

var enabled : bool = true

var source_mesh_name : String = ""
var output_name : String = ""

var output_path : String = ""

var resolution_x : int = 512
var resolution_y : int = 512

var bake_albedo : bool = true
var bake_metallic : bool = true
var bake_roughness : bool = true
var bake_normal : bool = true
var enable_alpha : bool = false

var bake_onto_self : bool = true
var bake_onto_other : bool = false

var done_baking : bool = false
var albedo_tex_path : String = ""
var roughness_tex_path : String = ""
var metallic_tex_path : String = ""
var normal_tex_path : String = ""

func paste(new_config : MeshBakingConfig):
	for property in new_config.get_property_list():
		if property.name in paste_immune_properties:
			continue
			
		set(property.name, new_config.get(property.name))
