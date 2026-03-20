@tool
extends CollisionShape3D
class_name CPMEffectShape

@export_flags_3d_render var layer : int = 0

var _forced_shape : SphereShape3D
var _previous_pos : Vector3 = Vector3.ZERO

func _enter_tree() -> void:
	CPMEffectShapeManager.register_shape(self)
	_forced_shape = SphereShape3D.new()
	_forced_shape.changed.connect(CPMEffectShapeManager.notify_dimensions_changed.bind(self))
	
func _exit_tree() -> void:
	CPMEffectShapeManager.deregister_shape(self)

func _process(delta: float) -> void:
	shape = _forced_shape
	
	if global_position != _previous_pos:
		if EditorInterface.is_plugin_enabled("CompositeMaterial"):
			CPMEffectShapeManager.notify_moved(self)
		else:
			printerr("Moving this EffectShape will have no effect because the CompositeMaterial plugin has been disabled.")
	
	_previous_pos = global_position
