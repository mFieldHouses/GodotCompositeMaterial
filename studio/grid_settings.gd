@tool
extends Window

var _grid_material : ShaderMaterial
var _grid_mesh : PlaneMesh

func _ready() -> void:
	close_requested.connect(func(): hide())
	
	_grid_mesh = %ground_plane.mesh
	_grid_material =  _grid_mesh.surface_get_material(0)
	
	$MarginContainer/VBox/visible.toggled.connect(func(state): %ground_plane.visible = state)
	$MarginContainer/VBox/opacity.value_changed.connect(func(value): _grid_material.set_shader_parameter("transparency", value))
	$MarginContainer/VBox/size.value_changed.connect(func(value): _grid_mesh.size = Vector2(value, value))
