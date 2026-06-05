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
		
		
		
func _ready() -> void:
	
	pass
	
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

func _validate_property(property: Dictionary) -> void:
	if property.name == "bake_status_hint":
		property.usage |= PROPERTY_USAGE_READ_ONLY
	
	elif property.name == "_internal_bake_status":
		property.usage = PROPERTY_USAGE_NO_EDITOR

func bake() -> void:
	CPMBaker.bake_popup(self)
