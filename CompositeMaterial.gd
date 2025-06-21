extends BaseMaterial3D
class_name CompositeMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _can_do_next_pass() -> bool:
	return false

func _can_use_render_priority() -> bool:
	return false
