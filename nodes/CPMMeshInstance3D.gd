@tool
extends MeshInstance3D
class_name CPMMeshInstance3D

##Extension of the MeshInstance3D class that allows you to take full advantage of CompositeMaterial.

signal global_position_changed(new_global_position : Vector3)

@export_tool_button("Update") var update_action = update_materials
@export_tool_button("Bake") var bake_action = bake
@export_tool_button("Unbake") var unbake_action = revert_bake

var previous_global_position : Vector3 = Vector3.ZERO

@export var autobake : bool = true

@export var bake_radius : float = 100.0

var baked : bool = false
var previous_camera_distance : float = 0.0
var within_bake_radius : bool = true

var original_materials : Dictionary[int, CompositeMaterial] = {}
var baked_materials : Dictionary[int, BaseMaterial3D] = {}

func _ready() -> void:
	previous_global_position = global_position
	
	if autobake:
		CPMBaker.request_bake(self)
	
	within_bake_radius = get_viewport().get_camera_3d().global_position.distance_to(global_position) < bake_radius
	
	#update_materials()
	#mesh.changed.connect(update_materials)

func update_materials() -> void:
	
	return
	var materials : Array[ShaderMaterial] = []
	if mesh is PrimitiveMesh:
		materials.append(mesh.material)
	else:
		for surface_idx in mesh.get_surface_count():
			var surface_material : Material = get_active_material(surface_idx)
			
			if surface_material is ShaderMaterial:
				materials.append(surface_material)
	
	CPMLineMapManager.register_mesh_instance(self, materials)

#func _exit_tree() -> void:
	#CPMLineMapManager.deregister_mesh_instance(self)

func _process(delta: float) -> void:
	if global_position != previous_global_position:
		global_position_changed.emit(global_position)
	
	previous_global_position = global_position
	
	if Engine.is_editor_hint() or !autobake:
		return
	
	var camera = get_viewport().get_camera_3d()
	var distance = camera.global_position.distance_to(global_position)
	#print(distance)
	#print(within_bake_radius)
	#print(distance > bake_radius and within_bake_radius)
	
	if distance > bake_radius and within_bake_radius:
		print('exit')
		_exit_bake_radius()
	elif distance < bake_radius and !within_bake_radius:
		print("enter")
		_enter_bake_radius()
	
	
	

func _enter_bake_radius() -> void:
	within_bake_radius = true
	if baked:
		revert_bake()

func _exit_bake_radius() -> void:
	within_bake_radius = false
	if baked:
		reapply_bake()
	else:
		bake()
		baked = true


func bake() -> void:
	CPMBaker.request_bake(self, true)

func revert_bake() -> void:
	for surface_index : int in original_materials:
		mesh.surface_set_material(surface_index, original_materials[surface_index])

func reapply_bake() -> void:
	for surface_index : int in baked_materials:
		if baked_materials.has(surface_index):
			mesh.surface_set_material(surface_index, baked_materials[surface_index])
