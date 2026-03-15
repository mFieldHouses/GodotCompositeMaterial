extends Resource
class_name CPM_VariableDeclaration

@export var variable_type : Variant.Type

func setup_from_resource(resource : CPMB_Base) -> void:
	if !resource.is_variable:
		printerr("setup_from_resource(): Resource is not a variable. Aborting.")
		return
	
	if resource is CPMB_IntValue:
		variable_type = TYPE_INT
	elif resource is CPMB_FloatValue:
		variable_type = TYPE_FLOAT
	elif resource is CPMB_BoolValue:
		variable_type = TYPE_BOOL
	elif resource is CPMB_Vector3Value:
		variable_type = TYPE_COLOR
	elif resource is CPMB_ComposeVec3:
		variable_type = TYPE_VECTOR3
	elif resource is CPMB_ComposeVec2:
		variable_type = TYPE_VECTOR2
