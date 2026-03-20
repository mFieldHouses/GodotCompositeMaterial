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

@export var used_names : Dictionary[String, int] = {}
@export var displayed_variables : Dictionary[String, Dictionary] = {}
@export var cached_values : Dictionary[String, Variant] = {}

func update_all() -> void:
	used_names.clear()
	print("updating all")
	print("used_names is ", used_names)
	update_shader()
	emit_changed()

func get_variable_name(name : String) -> String:
	print("get_variable_name() for ", name)
	var _result : String = name
	
	if name == "":
		return ""
	
	if !used_names.has(name):
		used_names[name] = 1
	else:
		used_names[name] += 1
		_result = name + " " + str(used_names[name])
	
	print("returning ", _result)
	return _result

func update_shader() -> void:
	print("updating shader")
	var _base_shader : Shader = base_composite_material.shader
	
	shader = _base_shader.duplicate()

	for uniform in _base_shader.get_shader_uniform_list():
		var _uniform_name : String = uniform.name
		#print("set ", _uniform_name, " to ", base_composite_material.get_shader_parameter(_uniform_name))
		#print(base_composite_material.get_shader_parameter(_uniform_name))
		var _val : Array = base_composite_material.get_shader_parameter(_uniform_name).duplicate()
		
		if _val[0] is GradientTexture1D: #duplicate color ramps so we can edit those independently
			print(_val)
			var _tmp_val : Array = []
			
			for _color_ramp : GradientTexture1D in _val:
				_tmp_val.append(_color_ramp.duplicate_deep(Resource.DEEP_DUPLICATE_ALL))
			
			_val = _tmp_val
		
		set_shader_parameter(_uniform_name, _val)
	
	
	print('all shader uniforms have been set')
	
	for variable_resource : CPMB_Base in base_composite_material.variable_resources:
		print("============== checking variable resource ", variable_resource)
		
		var variable_type : Variant.Type = 0
		var variable_name : String = get_variable_name(variable_resource.variable_name)
		var uniform_name : String = ""
		
		var hint : int = 0
		var hint_string : String = ""
		
		if variable_name == "":
			printerr("Found empty variable, continuing")
			continue
		
		if variable_resource is CPMB_TextureConfiguration:
			#print("found a texture")
			variable_type = TYPE_OBJECT
			uniform_name = "linear_textures"
			hint = PROPERTY_HINT_RESOURCE_TYPE
			hint_string = "Texture2D"
		elif variable_resource is CPMB_ColorRampConfiguration:
			#print("found a color ramp")
			variable_type = TYPE_OBJECT
			uniform_name = "color_ramp_textures"
			hint = PROPERTY_HINT_RESOURCE_TYPE
			hint_string = "GradientTexture1D"
		elif variable_resource is CPMB_IntValue:
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
			
			var _c = get_shader_parameter(uniform_name)[variable_resource.index]
			var color : Color
			if _c is Vector3:
				color = Color(_c.x, _c.y, _c.z)
			elif _c is Color:
				color = _c
			
			displayed_variables[variable_name] = {
				"resource": variable_resource,
				"uniform_name": uniform_name,
				"value": color,
				"type": variable_type,
				"hint": hint,
				"hint_string": hint_string,
				"index_in_uniform": variable_resource.index,
				"variable_name": variable_name
			}
			
			continue
			
		elif variable_resource is CPMB_ComposeVec3:
			variable_type = TYPE_VECTOR3
		elif variable_resource is CPMB_ComposeVec2:
			variable_type = TYPE_VECTOR2
		
		print("uniform name: ", uniform_name)
		print("value: ", get_shader_parameter(uniform_name)[variable_resource.index])
		
		displayed_variables[variable_name] = {
			"resource": variable_resource,
			"uniform_name": uniform_name,
			"value": get_shader_parameter(uniform_name)[variable_resource.index],
			"type": variable_type,
			"hint": hint,
			"hint_string": hint_string,
			"index_in_uniform": variable_resource.index,
			"variable_name": variable_name
		}
		
		if variable_resource is CPMB_TextureConfiguration or variable_resource is CPMB_ColorRampConfiguration:
			displayed_variables[variable_name].index_in_uniform = variable_resource.texture_index
			displayed_variables[variable_name].value = get_shader_parameter(uniform_name)[variable_resource.texture_index]
		
		if cached_values.has(variable_name) and displayed_variables.has(variable_name):
			displayed_variables[variable_name].value = cached_values[variable_name]
		
		cached_values[variable_name] = displayed_variables[variable_name].value
	
	for value_name in cached_values:
		set(value_name, cached_values[value_name])
	
	print("generated displayed_variables")
	
	
func _get_property_list() -> Array[Dictionary]:
	print("get property list")
	var _property_list : Array[Dictionary] = [
		{
			"name": "Material Variables",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_GROUP
		}
	]
	
	for variable in displayed_variables:
		_property_list.append({
			"name": displayed_variables[variable].variable_name,
			"type": displayed_variables[variable].type,
			"hint": displayed_variables[variable].hint,
			"hint_string": displayed_variables[variable].hint_string
		})
	
	return _property_list

var test : int = 0

func _set(property: StringName, value: Variant) -> bool:
	if displayed_variables.has(property):
		displayed_variables[property].value = value
		
		print("set")
		var array : Array = get_shader_parameter(displayed_variables[property].uniform_name)
		array[displayed_variables[property].index_in_uniform] = value
		#print(array)
		set_shader_parameter(displayed_variables[property].uniform_name, array)
		
		if displayed_variables[property].uniform_name == "linear_textures":
			set_shader_parameter("nearest_neighbor_textures", array)
		
		cached_values[property] = value
		
		return true
	
	return false

func _get(property: StringName) -> Variant:
	if displayed_variables.has(property):
		return displayed_variables[property].value
	
	return null
