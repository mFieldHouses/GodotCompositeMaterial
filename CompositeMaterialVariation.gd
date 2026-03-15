@tool
extends ShaderMaterial
class_name CompositeMaterialVariation

@export_multiline("Variation note") var variation_notes : String

@export var base_composite_material : CompositeMaterial:
	set(x):
		base_composite_material = x
		if base_composite_material != null:
			update_shader()

var displayed_variables : Dictionary[String, Dictionary] = {}

func update_shader() -> void:
	shader = base_composite_material.shader.duplicate()

func _get_property_list() -> Array[Dictionary]:
	var _property_list : Array[Dictionary] = [
		{
			"name": "Material Variables",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_CATEGORY
		}
	]
	
	for variable_resource : CPMB_Base in base_composite_material.variable_resources:
		
		var variable_type : Variant.Type = 0
		var uniform_name : String = ""
		
		if variable_resource is CPMB_IntValue:
			variable_type = TYPE_INT
		elif variable_resource is CPMB_FloatValue:
			variable_type = TYPE_FLOAT
		elif variable_resource is CPMB_BoolValue:
			variable_type = TYPE_BOOL
		elif variable_resource is CPMB_Vector3Value:
			variable_type = TYPE_COLOR
		elif variable_resource is CPMB_ComposeVec3:
			variable_type = TYPE_VECTOR3
		elif variable_resource is CPMB_ComposeVec2:
			variable_type = TYPE_VECTOR2
		
		displayed_variables[variable_resource.variable_name] = {
			"resource": variable_resource,
			"uniform_name": uniform_name
		}
		
		_property_list.append({
			"name": variable_resource.variable_name,
			"type": variable_type
		})
	
	return _property_list

var test : int = 0

func _set(property: StringName, value: Variant) -> bool:
	if property == "test variable":
		test = value
		return true
	
	return false

func _get(property: StringName) -> Variant:
	if property == "test variable":
		return test
	
	return null
