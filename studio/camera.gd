@tool
extends Camera3D

@onready var pivot = get_parent()

var pivot_engage = false
var pan_engage = false

var listen_to_direct_inputs : bool = true

var distance_to_pivot = 5.0
var min_distance_to_pivot = 0.5
var max_distance_to_pivot = 100.0

var _camera_configs : Array[Dictionary] = []
var _current_config_idx : int


func _enter_tree() -> void:
	get_tree().get_first_node_in_group("root_control").tab_pressed.connect(_load_config)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pivot_engage = Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)
	pan_engage = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) or (Input.is_key_pressed(KEY_SHIFT) and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE))
	
	distance_to_pivot = clamp(distance_to_pivot, min_distance_to_pivot, max_distance_to_pivot)
	position.z = lerp(position.z, distance_to_pivot, 0.7)

func input_event(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if pan_engage == true:
			pivot.position -= global_basis * Vector3(event.relative.x, -event.relative.y, 0.0) / 500 * distance_to_pivot
		elif pivot_engage == true:
			pivot.rotation += Vector3(event.relative.y, event.relative.x, 0) / (-70 * PI)
	
	if event is InputEventMouseButton:
		if listen_to_direct_inputs:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_in()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: 
				zoom_out()
		
func zoom_in() -> void:
	distance_to_pivot -= 0.1 * distance_to_pivot

func zoom_out() -> void:
	distance_to_pivot += 0.1 * distance_to_pivot

func _load_config(index : int) -> void:
	if index > _camera_configs.size() - 1:
		_camera_configs.append({"distance": 3.0, "rotation_degrees": Vector3(-30.0, 45.0, 0.0), "pivot_position" : Vector3(0.0, 1.5, 0.0)})
	else:
		_camera_configs[_current_config_idx] = {"distance": position.z, "rotation_degrees": get_parent().rotation_degrees, "pivot_position": get_parent().position}
	
	_current_config_idx = index
	get_parent().rotation_degrees = _camera_configs[index].rotation_degrees
	get_parent().position = _camera_configs[index].pivot_position
	position.z = _camera_configs[index].distance
	distance_to_pivot = _camera_configs[index].distance
