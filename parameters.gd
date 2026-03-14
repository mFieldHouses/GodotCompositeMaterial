@tool
extends EditorInspectorPlugin

var hide_parameters = ["_shader", "next_pass", "render_priority", "identifier", "source_identifier"]
var hide_when_frozen = ["layers", "autolock_material", "freeze_action", "rebuild_action"]
var hide_when_not_frozen = ["unfreeze_action"]

func _can_handle(object):
	return object is CompositeMaterial or object is CompositeMaterialLayer


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
		#print("parse property")
		if name in hide_parameters:
			return true
		elif object is CompositeMaterial:
			if object.frozen:
				if name in hide_when_frozen:
					return true
			else:
				if name in hide_when_not_frozen:
					return true
		
		return false
