@tool
extends ShaderMaterial
class_name CompositeMaterialVariation

@export_multiline("Variation note") var variation_notes : String

@export var variations : Dictionary[String, Variant]

@export var base_composite_material : CompositeMaterial:
	set(x):
		if base_composite_material:
			base_composite_material.finish_building.disconnect(_update_shader)	
		
		base_composite_material = x
		base_composite_material.finish_building.connect(_update_shader)

func _update_shader() -> void:
	print("updated shader from base compositematerial")
	shader = base_composite_material.shader
