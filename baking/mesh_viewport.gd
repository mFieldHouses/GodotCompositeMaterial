@tool
extends SubViewportContainer

@onready var camera = get_node("preview_viewport/camera_pivot/Camera3D")
@onready var pivot = get_node("preview_viewport/camera_pivot")

var dragging : bool = false
var listening : bool = false

func _input(event: InputEvent) -> void:
	if listening:
		if event is InputEventMouseButton: 
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					camera.position.z -= 0.25
					
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					camera.position.z += 0.25
			
			elif event.button_index == MOUSE_BUTTON_LEFT:
				dragging = event.pressed
		
			if camera.position.z < 0.1:
				camera.position.z = 0.1
		
		if event is InputEventMouseMotion:
			if dragging:
				pivot.rotation.x -= event.relative.y / 100
				pivot.rotation.y -= event.relative.x / 100



func _on_mouse_entered() -> void:
	listening = true


func _on_mouse_exited() -> void:
	listening = false
