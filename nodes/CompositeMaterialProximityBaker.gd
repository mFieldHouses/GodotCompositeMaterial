extends Node3D
class_name CompositeMaterialProximityBaker

##Node that automatically bakes models using CompositeMaterial while the game is running based on the distance to the active camera.

@export var threshold_distance : float = 5.0

var _current_active_camera : Camera3D
var _baked : bool = false

func _process(delta: float) -> void:
	_current_active_camera = get_tree().root.get_camera_3d()
	
	if _baked: #just skip if you've already baked
		return
	
	if (_current_active_camera.global_position - global_position).length() <= threshold_distance:
		_bake_self()

func _bake_self() -> void:
	print("bake")
	_baked = true
	
	DirAccess.make_dir_absolute("user://gamedata/test")
	
	var _bake_tool_instance : Node3D = preload("res://addons/CompositeMaterial/baking/shader_baking.tscn").instantiate()
	add_child(_bake_tool_instance)
	
	var _new_config := MeshBakingConfig.new()
	_new_config.albedo_tex_path
