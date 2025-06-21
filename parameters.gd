@tool
extends EditorInspectorPlugin

var disable_parameters = ["shader","next_pass", "render_priority", "layer_base_metallic_map"]

func _can_handle(object):
	return object is CompositeMaterial


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
		if name in disable_parameters:
			return true
		
		if usage_flags & 4 == 4:
			return true
		#if usage_flags == 4102:
			#return true
		
		print(usage_flags, " / ", usage_flags & 256)
		
		
		return false

func _parse_group(object: Object, group: String) -> void:
