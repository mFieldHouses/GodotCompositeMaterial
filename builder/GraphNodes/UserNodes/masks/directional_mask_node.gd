@tool
extends MaskNode

var represented_configuration : CPMB_DirectionalMaskConfiguration

var _dragging_viewport : bool = false
var _drag_direction : int = 1

func _node_ready() -> void:
	$SubViewportContainer.gui_input.connect(_viewport_input)
	
	$template_directions/x.button_down.connect(func(): $SubViewportContainer/SubViewport/pointer_origin.rotation_degrees = Vector3(-90.0, -90.0, 0.0); represented_configuration.direction = $SubViewportContainer/SubViewport/pointer_origin/normal_point.global_position)
	$template_directions/y.button_down.connect(func(): $SubViewportContainer/SubViewport/pointer_origin.rotation_degrees = Vector3(0.0, 0.0, 0.0); represented_configuration.direction = $SubViewportContainer/SubViewport/pointer_origin/normal_point.global_position)
	$template_directions/z.button_down.connect(func(): $SubViewportContainer/SubViewport/pointer_origin.rotation_degrees = Vector3(90.0, 0.0, 0.0); represented_configuration.direction = $SubViewportContainer/SubViewport/pointer_origin/normal_point.global_position)
	
	$polarity.item_selected.connect(func(idx : int): represented_configuration.polarity = idx)
	
	represented_configuration = CPMB_DirectionalMaskConfiguration.new()
	
func _viewport_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_dragging_viewport = event.pressed
			if cos($SubViewportContainer/SubViewport/pointer_origin.rotation.y) >= 0:
				_drag_direction	= 1
			else:
				_drag_direction	= -1
	
	elif event is InputEventMouseMotion:
		if _dragging_viewport:
			$SubViewportContainer/SubViewport/pointer_origin.rotation.x += event.relative.y / 100
			$SubViewportContainer/SubViewport/pointer_origin.rotation.y += event.relative.x / 100 * _drag_direction
			represented_configuration.direction = $SubViewportContainer/SubViewport/pointer_origin/normal_point.global_position

			
func get_represented_object(port_idx : int) -> Object:
	return represented_configuration

func set_represented_object(object : Object) -> void:
	represented_configuration = object
