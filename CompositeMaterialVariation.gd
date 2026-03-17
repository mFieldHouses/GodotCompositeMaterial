@tool
extends ShaderMaterial
class_name CompositeMaterialVariation

@export_multiline("Variation note") var variation_notes : String

@export var base_composite_material : CompositeMaterial: ##The CompositeMaterial on which this variation is based.
	set(x):
		base_composite_material = x
		if base_composite_material != null:
			update_shader()
			base_composite_material.finish_building.connect(func(): if update_automatically: update_all())

@export_tool_button("Update", "Reload") var update_manual : Callable = update_all ##Manually update this variation.
@export var update_automatically : bool = true ##Whether this variation automatically updates when the source material is rebuilt.

@export var displayed_variables : Dictionary[String, Dictionary] = {}

func update_all() -> void:
	print("updating all")
	update_shader()
	emit_changed()

func update_shader() -> void:
	print("updating")
	var _base_shader : Shader = base_composite_material.shader
	
	shader = _base_shader.duplicate()
	
	for uniform in _base_shader.get_shader_uniform_list():
		var _uniform_name : String = uniform.name
		set_shader_parameter(_uniform_name, base_composite_material.get_shader_parameter(_uniform_name))
		print('set ', _uniform_name, " to ", base_composite_material.get_shader_parameter(_uniform_name))
	
	print('all shader uniforms have been set')
	
func _get_property_list() -> Array[Dictionary]:
	print("get property list")
	var _property_list : Array[Dictionary] = [
		{
			"name": "Material Variables",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_GROUP
		}
	]
	
	displayed_variables = {}
	
	#print(base_composite_material.variable_resources)
	for variable_resource : CPMB_Base in base_composite_material.variable_resources:
		
		var variable_type : Variant.Type = 0
		var uniform_name : String = ""
		
		if variable_resource.variable_name == "":
			printerr("Found empty variable, continuing")
			continue
		
		if variable_resource is CPMB_IntValue:
			variable_type = TYPE_INT
			uniform_name = "int_values"
		elif variable_resource is CPMB_FloatValue:
			variable_type = TYPE_FLOAT
			uniform_name = "float_values"
		elif variable_resource is CPMB_BoolValue:
			variable_type = TYPE_BOOL
			uniform_name = "bool_values"
		elif variable_resource is CPMB_Vector3Value:
			variable_type = TYPE_COLOR
			uniform_name = "vector3_values"
			
			displayed_variables[variable_resource.variable_name] = {
				"resource": variable_resource,
				"uniform_name": uniform_name,
				"value": get_shader_parameter(uniform_name)[variable_resource.index],
				"type": variable_type,
				"index_in_uniform": variable_resource.index
			}
			
			_property_list.append({
				"name": variable_resource.variable_name,
				"type": variable_type
			})
			
			continue
			
		elif variable_resource is CPMB_ComposeVec3:
			variable_type = TYPE_VECTOR3
		elif variable_resource is CPMB_ComposeVec2:
			variable_type = TYPE_VECTOR2
		
		displayed_variables[variable_resource.variable_name] = {
			"resource": variable_resource,
			"uniform_name": uniform_name,
			"value": get_shader_parameter(uniform_name)[variable_resource.index],
			"type": variable_type,
			"index_in_uniform": variable_resource.index
		}
		
		#print("resource", variable_resource, " has index ", variable_resource.index)
		
		_property_list.append({
			"name": variable_resource.variable_name,
			"type": variable_type
		})
	
	return _property_list

var test : int = 0

func _set(property: StringName, value: Variant) -> bool:
	if displayed_variables.has(property):
		displayed_variables[property].value = value
		
		#print("set")
		var array : Array = get_shader_parameter(displayed_variables[property].uniform_name)
		array[displayed_variables[property].index_in_uniform] = value
		#print(array)
		set_shader_parameter(displayed_variables[property].uniform_name, array)
		
		return true
	
	return false

func _get(property: StringName) -> Variant:
	if displayed_variables.has(property):
		return displayed_variables[property].value
	
	return null
