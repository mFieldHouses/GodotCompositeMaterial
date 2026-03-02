extends CollisionShape3D
class_name CPMEffectShape

@export_flags_3d_render var layer : int = 0

func _enter_tree() -> void:
	CPMEffectShapeManager.register_shape(self)

func _exit_tree() -> void:
	CPMEffectShapeManager.deregister_shape(self)
