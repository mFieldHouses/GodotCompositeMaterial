@tool
extends Node3D
class_name CPMModel

@export var bake_status_hint : String = "None"
@export_tool_button("Bake...", "Bake") var bake_action : Callable = bake

var bake_status_strings : Array[String] = [
	"None",
	"Imported model",
	"All instances",
	"This instance"
]

@export var _internal_bake_status : int = 0: # 0 = None, 1 = Imported model, 2 = All instances, 3 = This instance
	set(x):
		bake_status_hint = bake_status_strings[x]
		_internal_bake_status = x
		

@export var _internal_baked_albedo_texture : Texture2D
@export var _internal_baked_normal_texture : Texture2D
@export var _internal_baked_orm_texture : Texture2D

		
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if _internal_bake_status == 0:
		return
		
	var meshes_to_bake : Dictionary[MeshInstance3D, Array] = {}
			
	for node : Node in get_children_recursive(self):
		if node is not MeshInstance3D:
			continue
				
		var surfaces_to_bake : Array[int] = []
		for i in node.mesh.get_surface_count():
			if node.get_active_material(i) is CompositeMaterial:
				surfaces_to_bake.append(i)
		
		meshes_to_bake[node as MeshInstance3D] = surfaces_to_bake
	
	var _subresources_config : Dictionary
	
	#print("ready: ", self)
	#print(_internal_bake_status)
	
	if CPMBaker.imported_baked_scenes.has(scene_file_path) and _internal_bake_status < 2:
		#print("found in cache 1")
		_internal_bake_status = 1
	
	#elif CPMBaker.imported_non_baked_scene_paths.has(scene_file_path) and _internal_bake_status < 2:
		#print("found in anti-cache 1")
	
	elif _internal_bake_status < 2:
		#print("not found in cache, need to read file 1")
		var import_file_path : String = scene_file_path + ".import"
		var import_file : ConfigFile = ConfigFile.new()
		import_file.load(import_file_path)
		
		_subresources_config = import_file.get_value("params", "_subresources")

		if _subresources_config.has("cpm/baked"):
			if _subresources_config["cpm/baked"] == true:
				_internal_bake_status = 1 # just force the model to use imported model bakes
	
	if _internal_bake_status == 1:
		#print("imported model bakes")
		
		var albedo_texture : Texture2D
		var normal_texture : Texture2D
		var orm_texture : Texture2D
		
		if CPMBaker.imported_baked_scenes.has(scene_file_path):
			#print("found in cache 2")
			
			return
			
			#for node : MeshInstance3D in meshes_to_bake:
				#var surfaces_to_bake : Array[int] = meshes_to_bake[node]
				#
				#for index : int in surfaces_to_bake:
					#var material : CompositeMaterial = node.get_active_material(index).duplicate(true)
					#
					#CPMBaker.imported_baked_scenes[scene_file_path].mesh_surface_materials[node][index] = material
					#
					#material.set_shader_parameter("baked_albedo", albedo_texture)
					#material.set_shader_parameter("baked_normal", normal_texture)
					#material.set_shader_parameter("baked_orm", orm_texture)
					#material.set_shader_parameter("bake_display_mode", 1)
					#
					#node.mesh.surface_set_material(index, material)
			
		else:
			#print("not found in cache, need to read file 2")
			if !_subresources_config.has("cpm/baked"):
				return
		
			if _subresources_config["cpm/baked"] == false:
				return
		
			if !_subresources_config.has("cpm/baked_albedo_texture"):
				printerr("CPMModel: Imported model appears to be baked in .import file, but does not possess over baked textures: ", scene_file_path)
				return
			
			albedo_texture = load(_subresources_config["cpm/baked_albedo_texture"])
			normal_texture = load(_subresources_config["cpm/baked_normal_texture"])
			orm_texture = load(_subresources_config["cpm/baked_orm_texture"])
		
			CPMBaker.imported_baked_scenes[scene_file_path] = {
				"albedo_texture": albedo_texture.resource_path,
				"normal_texture": albedo_texture.resource_path,
				"orm_texture": albedo_texture.resource_path,
				"mesh_surface_materials": {}
			}
			
			#print(CPMBaker.imported_baked_scenes)
			
			for node : MeshInstance3D in meshes_to_bake:
				#print(node)
				var surfaces_to_bake : Array[int] = meshes_to_bake[node]
				
				CPMBaker.imported_baked_scenes[scene_file_path].mesh_surface_materials[node] = {}
				
				for index : int in surfaces_to_bake:
					var material : CompositeMaterial = node.get_active_material(index).duplicate(true)
					
					CPMBaker.imported_baked_scenes[scene_file_path].mesh_surface_materials[node][index] = material
					
					material.set_shader_parameter("baked_albedo", albedo_texture)
					material.set_shader_parameter("baked_normal", normal_texture)
					material.set_shader_parameter("baked_orm", orm_texture)
					material.set_shader_parameter("bake_display_mode", 1)
					
					node.mesh.surface_set_material(index, material)
		
	elif _internal_bake_status >= 2:
		#print("instance bakes")
		if _internal_baked_albedo_texture:
			
			if !CPMBaker.imported_non_baked_scene_paths.has(scene_file_path):
				CPMBaker.imported_non_baked_scene_paths.append(scene_file_path)
			
			for node : MeshInstance3D in meshes_to_bake:
				var surfaces_to_bake : Array[int] = meshes_to_bake[node]
				
				node.mesh = node.mesh.duplicate()
				
				for index : int in surfaces_to_bake:
					#print("old material: ", node.get_active_material(index))
					var material : CompositeMaterial = node.get_active_material(index).duplicate(true)
					#print("new material: ", material)
					
					#print("setting textures on ", self)
					material.set_shader_parameter("baked_albedo", _internal_baked_albedo_texture)
					material.set_shader_parameter("baked_normal", _internal_baked_normal_texture)
					material.set_shader_parameter("baked_orm", _internal_baked_orm_texture)
					material.set_shader_parameter("bake_display_mode", 1)
					
					node.mesh.surface_set_material(index, material)
				
				meshes_to_bake[node as MeshInstance3D] = surfaces_to_bake
			#print(node, ": ", node.mesh.surface_get_material(0), " ", node.mesh.surface_get_material(0).baking_mode)
	
	
	#var import_file_path : String = scene_file_path + ".import"
	#var import_file : ConfigFile = ConfigFile.new()
	#import_file.load(import_file_path)
	#
	#if import_file.get_value("cpm", "baked") == false:
		#return
	#
	#for i in get_children():
		#if i is MeshInstance3D:
			#
			#var surfaces : Array[int] = []
			#for index in i.mesh.get_surface_count():
				#if i.get_active_material(index) is CompositeMaterial:
					#surfaces.append(index)
			#
			#if surfaces.size() == 0:
				## Mesh has no compositematerials
				#continue
			#
			#i.mesh = i.mesh.duplicate(true)

func get_children_recursive(node : Node) -> Array[Node]:
	var _result : Array[Node] = []
	var _children_to_be_checked : Array[Node] = []
	
	for _child in node.get_children():
		_children_to_be_checked.append(_child)
	
	while _children_to_be_checked.size() > 0:
		var _child_to_check : Node = _children_to_be_checked[0]
		for _subchild in _child_to_check.get_children():
			_children_to_be_checked.append(_subchild)
		
		_result.append(_child_to_check)
		_children_to_be_checked.erase(_child_to_check)
	
	return _result

func _validate_property(property: Dictionary) -> void:
	if property.name == "bake_status_hint":
		property.usage |= PROPERTY_USAGE_READ_ONLY
	
	#elif property.name == "_internal_bake_status" or property.name ==  "_internal_baked_albedo_texture" or property.name == "_internal_baked_normal_texture" or property.name == "_internal_baked_orm_texture":
		#property.usage = PROPERTY_USAGE_NO_EDITOR

func bake() -> void:
	CPMBaker.bake_popup(self)
