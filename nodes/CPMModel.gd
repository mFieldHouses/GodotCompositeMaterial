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
		

@export var _internal_baked_albedo_texture : Texture2D:
	set(x):
		print("albedo texture got set")
		_internal_baked_albedo_texture = x
@export var _internal_baked_normal_texture : Texture2D
@export var _internal_baked_orm_texture : Texture2D

		
func _ready() -> void:
	
	if Engine.is_editor_hint():
		return
	
	if _internal_baked_albedo_texture:
		var meshes_to_bake : Dictionary[MeshInstance3D, Array] = {}
		
		for node : Node in get_children_recursive(self):
			if node is not MeshInstance3D:
				continue
			
			var surfaces_to_bake : Array[int] = []
			for i in node.mesh.get_surface_count():
				if node.get_active_material(i) is CompositeMaterial:
					surfaces_to_bake.append(i)
			
			for index : int in surfaces_to_bake:
				var material : CompositeMaterial = node.get_active_material(index).duplicate(true)
				
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
	
	elif property.name == "_internal_bake_status" or property.name ==  "_internal_baked_albedo_texture" or property.name == "_internal_baked_normal_texture" or property.name == "_internal_baked_orm_texture":
		property.usage = PROPERTY_USAGE_NO_EDITOR

func bake() -> void:
	CPMBaker.bake_popup(self)
