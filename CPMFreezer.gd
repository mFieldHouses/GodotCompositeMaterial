@tool
extends Node
#Dictionary
var feature_functions = {
	"texture_mask": "float get_texture_mask_for_layer",
	"directional_mask": "float get_directional_mask_for_layer",
	"positional_mask": "float get_positional_mask_for_layer",
	"vertex_color_mask": "float get_vertex_color_mask_for_layer",
	"normal_map_slope_mask": "float get_normal_map_slope_mask_for_layer",
	"uv_mask": "float get_uv_mask_for_layer"
}

enum FunctionType {UNKNOWN, FIRST_ORDER, SECOND_ORDER, TEXTURE_FETCH}

class FunctionIndexEntry:
	var full_signature : String:
		set(x):
			full_signature = x
			argument_names = full_signature.split("(")[1].rstrip(")").replace("float", "").replace("int", "").replace(" ", "").split(",")
			#print("argument names:", argument_names)
	var type : FunctionType
	var index : int
	var line : int
	var expression : String
	var argument_names : PackedStringArray
	
	func _init(full_signature : String, type : FunctionType = FunctionType.UNKNOWN, index : int = 0, line : int = 0, expression : String = "") -> void:
		self.full_signature = full_signature
		self.type = type
		self.index = index
		self.line = line
		self.expression = expression

class FunctionCall:
	var full_call : String:
		set(x):
			full_call = x
			parameters = full_call.split("(")[1].rstrip(")").replace(" ", "").split(",")
			var _idx : int = 0
			for param : String in parameters:
				if param.is_valid_float():
					parameters[_idx] = float(param)
				elif param.is_valid_int():
					parameters[_idx] = int(param)
				_idx += 1
			print(parameters)
			
	var function_name : String
	var parameters : Array[Variant]
	
	func are_all_arguments_values() -> bool:
		var result : bool = true
		
		for param in parameters:
			if param is String:
				result = false
		
		return result

func freeze_cpm(material : CompositeMaterial) -> void:
	
	print("Freezing CompositeMaterial resource...")
	
	var function_index : Dictionary[String, FunctionIndexEntry]
	var uniform_index : Dictionary[String, Variant]
	
	var used_features : Array[String]
	var add_used_feature : Callable = func add_used_feature(feature_name : String) -> void:
		if !used_features.has(feature_name):
			used_features.append(feature_name)
	
	for layer in material.layers:
		if layer.texture_mask_A_enabled or layer.texture_mask_B_enabled:
			add_used_feature.call("texture_mask")
		if layer.directional_mask_mode != 0:
			add_used_feature.call("directional_mask")
		if layer.positional_mask_mode != 0:
			add_used_feature.call("positional_mask")
		if layer.vertex_color_mask_mode != 0:
			add_used_feature.call("vertex_color_mask")
		if layer.UV_mask_enabled:
			add_used_feature.call("uv_mask")
		if layer.normal_map_slope_mask_mode != 0:
			add_used_feature.call("normal_map_slope_mask")
	
	var _shader_code : String = material.shader.code
	
	var unused_features : Array = feature_functions.keys()
	for i in used_features:
		unused_features.erase(i)
	
	for uf : String in unused_features:
		var _function_name : String = feature_functions[uf]
		var _idx_in_code : int = _shader_code.find(_function_name)
		var _full_function_signature : String
		
		#print(_function_name)
		
		var _idx : int = 0
		var _depth : int = 0
		var _found_function_end : bool = false
		var _found_function_signature : bool = false
		while _found_function_end == false:
			if _shader_code[_idx_in_code + _idx] == "{":
				_depth += 1
				#print("found {, depth = ", _depth)
			elif _shader_code[_idx_in_code + _idx] == "}":
				_depth -= 1
				#print("found }, depth = ", _depth)
				if _depth == 0:
					_found_function_end = true
			
			if _shader_code[_idx_in_code + _idx] == ")" and _found_function_signature == false:
				_full_function_signature = _shader_code.substr(_idx_in_code, _idx + 1)
				_found_function_signature = true
			
			_idx += 1
		
		_shader_code = _shader_code.erase(_idx_in_code, _idx)
		_shader_code = _shader_code.insert(_idx_in_code, _full_function_signature + " {return 0.0;}")
		
		#print("found function end: ", _idx)
	
	var bake_uniform_into_code : Callable = func x(uniform_name : String, value : Variant) -> void:
		pass
	
	for uniform : Dictionary in material.shader.get_shader_uniform_list():
		if uniform.type != 24:
			uniform_index[uniform.name] = material.get_shader_parameter(uniform.name)
			
	var _check_next_line_of_function : bool = false
	var _current_function_name : String = ""
	
	var _lines = _shader_code.split("\n")
	var _idx : int = 0
	for line in _lines:
		
		line = line.lstrip(" \t")
		
		if line.begins_with("//") or line.begins_with("*") or line.begins_with("/*"):
			_shader_code = _shader_code.replace(line, "")
		
		if line.begins_with("uniform"):
			var _uniform_name : String = _get_line_uniform_name(line)
			if uniform_index.has(_uniform_name):
				var _value : Variant
				var _value_string : String = str(uniform_index[_uniform_name])
				if uniform_index[_uniform_name] is Vector2:
					_value_string = "vec2" + str(uniform_index[_uniform_name])
				elif uniform_index[_uniform_name] is Vector3:
					_value_string = "vec3" + str(uniform_index[_uniform_name])
				
				_shader_code = _shader_code.replace(line, "")
				_shader_code = _shader_code.replace(_uniform_name + " ", _value_string + " ")
				_shader_code = _shader_code.replace(_uniform_name + ",", _value_string + ",")
				_shader_code = _shader_code.replace(_uniform_name + ")", _value_string + ")")
				_shader_code = _shader_code.replace(_uniform_name + ";", _value_string + ";")
		
		_idx += 1
	
	_lines = _shader_code.split("\n")
	_idx = 0
	for line in _lines:
		if _line_is_function_declaration(line):
			var _full_signature : String = line.trim_suffix(" {")
			_check_next_line_of_function = true
			_current_function_name = line.split(" ")[1].split("(")[0]
			function_index[_current_function_name] = FunctionIndexEntry.new(_full_signature)
		
		elif _check_next_line_of_function:
			if line.begins_with("return"):
				#print("begins with return: ", line)
				#print("function ", _current_function_name)
				function_index[_current_function_name].type = FunctionType.FIRST_ORDER
				function_index[_current_function_name].expression = line.rstrip(";").trim_prefix("return ")
				function_index[_current_function_name].index = _shader_code.find(_current_function_name)
			else:
				function_index.erase(_current_function_name)
			
			_check_next_line_of_function = false
		
		_idx += 1
	
	var _regex := RegEx.new()
	_regex.compile(r"[a-zA-Z_]+(?=\()")
	
	var _function_call_matches : Array[RegExMatch] = _regex.search_all(_shader_code, _shader_code.find("void fragment"))
	var _function_calls : Array[FunctionCall]
	
	for _match : RegExMatch in _function_call_matches:
		var _call : FunctionCall = FunctionCall.new()
		
		var _start_idx : int = _match.get_start()
		var _length : int = _match.get_end() - _start_idx
		var _function_name : String = _shader_code.substr(_start_idx, _length)
		
		var _ignore_function_names : Array[String] = ["float", "int", "mix", "vec2", "vec3", "texture", "textureLod", "fragment"]
		if _function_name in _ignore_function_names:
			continue
		
		_function_calls.append(_call)
		_call.function_name = _function_name

		var _full_call : String = ""
		
		var _depth : int = 0
		_idx = 0
		while _full_call == "":
			if _shader_code[_start_idx + _idx] == "(":
				_depth += 1
			elif _shader_code[_start_idx + _idx] == ")":
				_depth -= 1
				if _depth == 0:
					_full_call = _shader_code.substr(_start_idx, _idx + 1)
			
			_idx += 1
		
		_call.full_call = _full_call
	
	for fcall in _function_calls:
		var _function_name : String = fcall.function_name
		if fcall.are_all_arguments_values() and function_index[fcall.function_name].type == FunctionType.FIRST_ORDER:
			print("baking call ", fcall.full_call)
			#print(function_index[call.function_name].expression)
			
			var _exp := Expression.new()
			#print(function, ": ", function_index[function].expression)
			_exp.parse(function_index[_function_name].expression, function_index[_function_name].argument_names)
			var _resulting_value = _exp.execute(fcall.parameters)
			print("resulting value: ", _resulting_value)
			_shader_code = _shader_code.replace(fcall.full_call, str(_resulting_value))
	
	#var function_matches : Dictionary[String, Array] = {}
	#
	#var regex := RegEx.new()
	#for function in function_index:
		#regex.compile(function)
		#var matches : Array[RegExMatch] = regex.search_all(_shader_code)
		#if matches.size() > 0:
			#function_matches[function] = []
			##print("names: ", str(matches[0].get_start()), " ", matches[0].get_end() - matches[0].get_start())
		#
		#for _match : RegExMatch in matches:
			#function_matches[function].append(_match.get_start())
#
	#for function in function_matches:
		#print(function)
		#for match_idx in function_matches[function]:
			#var _full_function_call : String = ""
			#_idx = 0
			#var _depth : int = 0
			#while _full_function_call == "":
				#if _shader_code[match_idx + _idx] == "(":
					#_depth += 1
				#elif _shader_code[match_idx + _idx] == ")":
					#_depth -= 1
					#if _depth == 0:
						#_full_function_call = _shader_code.substr(match_idx, _idx + 1)
				#_idx += 1
			#
			##print("function call: ", _full_function_call)
			#var _args = _full_function_call.split("(")[1].rstrip(")").split(",")
			#var _parsed_args : Array[Variant]
			#
			#var _all_arguments_are_values : bool = true
			#for _arg : String in _args:
				#_arg = _arg.lstrip(" ").rstrip(" ")
				#if (_arg.is_valid_float() or _arg.is_valid_int()):
					#if _arg.is_valid_float():
						#_parsed_args.append(float(_arg))
					#else:
						#_parsed_args.append(int(_arg))
				#else:
					#_all_arguments_are_values = false
			#
			#if _all_arguments_are_values:
				#var _exp := Expression.new()
				##print(function, ": ", function_index[function].expression)
				#_exp.parse(function_index[function].expression, function_index[function].argument_names)
				#var _resulting_value = _exp.execute(_parsed_args)
				##print("resulting value: ", _resulting_value)
	
	#for char in _shader_code:
		#pass
	
	#var _result_code : String = ""
	#
	#for line in _shader_code.split("\n"):
		#line = line.replace(" ", "")
		#
		#if line.is_empty() or line == "\n":
			#return
		#
		#_result_code += line
	
	material.unfrozen_shader = material.shader
	var frozen_shader := Shader.new()
	frozen_shader.code = _shader_code
	material.shader = frozen_shader
	
	print("Freezing complete!")
	
func unfreeze_material(material : FrozenCompositeMaterial) -> void:
	_set_currently_selected_node_material(material.source_composite_material)

func _set_currently_selected_node_material(material : Material) -> void:
	var _node = EditorInterface.get_selection().get_selected_nodes()[0]
	
	if _node is MeshInstance3D:
		_node.mesh.surface_set_material(0, material)
		
func _line_is_function_declaration(_line : String):
	if _line.split(" ").size() < 2: return false
	return _line.split(" ")[1].contains("(") and (_line.begins_with("bool") or _line.begins_with("int") or _line.begins_with("vec2") or _line.begins_with("float") or _line.begins_with("vec3") or _line.begins_with("vec4"))

func _get_line_uniform_name(line : String) -> String:
	var _line_components : PackedStringArray = line.split(" ")
	for _comp in _line_components:
		if _comp.begins_with("layer"):
			return _comp.split(":")[0]
	
	return ""
