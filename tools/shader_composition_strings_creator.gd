extends Control

func _ready() -> void:
	$VBoxContainer/run.button_down.connect(run)


var _current_processing_state : String = "none":
		set(x):
			if _current_processing_state != "none" and x == "none":
				_current_processing_state = "none"
				_buffer = ""
			elif _current_processing_state == "none":
				_current_processing_state = x
			else:
				printerr("Illegal state change: from ", _current_processing_state, " to ", x, ". Have you removed/changed tags in the source shader file?")

var _awaiting_switch_statement : bool = false
var _create_sc_from_next_line : bool = false
var _ignore_new_cases : bool = false #used when the cursor is still in a function that we have already generated an sc for
var _temp_func_name : String = ""
var _base_string_buffer : String = ""
var _ignore_lines : bool = false
var _include_lines : bool = false

var _buffer : String = ""

var _sc_mappings : Dictionary[String, String] = {}

func run() -> void:
	var _source_file = FileAccess.open($VBoxContainer/input_path.text, FileAccess.READ)
	var _source_lines = _source_file.get_as_text().split("\n")
	
	var _output_file = FileAccess.open($VBoxContainer/output_path.text, FileAccess.WRITE)
	_output_file.store_line("#This script has been generated using addons/CompositeMaterial/tools/shader_composition_strings_creator.tscn.\n#It is advised you also use that script. It automates the whole process.")
	
	_output_file.store_line("const render_mode_shaded_string : String = 'shader_type spatial; render_mode cull_disabled, depth_prepass_alpha;' \nconst render_mode_unshaded_string : String = 'shader_type spatial; render_mode cull_disabled, depth_prepass_alpha, unshaded;'")
	
	for _raw_line : String in _source_lines:
		var _line = _raw_line.replace("\t", "")
		print(_current_processing_state)
		
		if _line.is_empty():
			print("<empty>")
			continue
		
		if _current_processing_state == "none":
			if _line.begins_with("//parameters_string"):
				_current_processing_state = "parameters_string"
				print("found parameters string")
				_buffer = "const parameters_string : String = '"
			elif _line.begins_with("//base_string"):
				_current_processing_state = "base_string"
			elif _line.begins_with("//base2_string"):
				_current_processing_state = "base2_string" #special case, gets appended to base_string
			elif _line.begins_with("//pre_base_string"):
				_current_processing_state = "pre_base_string"
			elif _line.begins_with("//fragment_snippet_string"):
				_current_processing_state = "fragment_snippet_string"
				print("found fragment snippet string")
				_buffer = "const fragment_snippet_string : String = '"
			continue
				
		
		if _line.begins_with("//end " + _current_processing_state):
			if _current_processing_state == "base2_string":
				_buffer = "const base_string : String = '" + _base_string_buffer + "'"
				print("inserting base string constant")
			elif _current_processing_state == "pre_base_string":
				_base_string_buffer += " %parameters "
			elif _current_processing_state == "base_string":
				_base_string_buffer += " %layer_fragment_snippets "
			elif !_current_processing_state.contains("base"):
				_buffer += "'"	
			
			_output_file.store_line(_buffer)
			_current_processing_state = "none"
			continue
		
		if _current_processing_state == "pre_base_string":
			var _clean_line : String = _line.replace("'", "")
			_base_string_buffer += _clean_line
		
		elif _current_processing_state == "parameters_string":
			var _clean_line : String = _line.replace("'", "").replace("layer_A", "layer_%s")
			_buffer += _clean_line
			
		elif _current_processing_state == "fragment_snippet_string":
			_buffer += _line.replace("layer_A", "layer_%s").replace("(1", "(%s")
		
		elif _current_processing_state == "base_string" or _current_processing_state == "base2_string":
			
			if _ignore_new_cases:
				if _line == "}":
					print("found closing bracket. Stop ignoring")
					_ignore_new_cases = false
				else:
					print("ignoring for now")
					continue
			
			if _line.begins_with("//ignore"):
				print("found ignore tag")
				_ignore_lines = true
			elif _line.begins_with("//end ignore"):
				print("found end ignore tag")
				_ignore_lines = false
			elif _ignore_lines:
				print("ignoring line ", _line)
				continue
			elif _line.begins_with("//include"):
				print("found include tag")
				_include_lines = true
			elif _line.begins_with("//end include"):
				print("found end include tag")
				_include_lines = false
			elif _include_lines:
				print("including ", _line.trim_prefix("//"))
				_base_string_buffer += _line.trim_prefix("//")
			
			elif _line.begins_with("//"): continue
			
			elif _line_is_function_declaration(_line) and (_line.begins_with("bool") or _line.begins_with("int") or _line.begins_with("vec2") or _line.begins_with("float") or _line.begins_with("vec3") or _line.begins_with("vec4")):
				print("found new function declaration: ", _line)
				_awaiting_switch_statement = true
				_temp_func_name = _line.split(" ")[1].split("(")[0]
				_base_string_buffer += _line + "\n"
			
			elif _awaiting_switch_statement:
				if _line.begins_with("switch (layer)"):
					print("function needs an sc")
					_base_string_buffer += _line + "%sc_" + _temp_func_name + "_sc_" #weird pattern stuff to prevent the String.replace() function from matching the wrong patterns
					_create_sc_from_next_line = true
				else:
					_base_string_buffer += _line
				
				_awaiting_switch_statement = false
			
			elif _create_sc_from_next_line:
				if _line == "case 1:":
					print("found case 1")
					continue
				else:
					print("generating sc line, adding to _sc_mappings")
					var _clean_line : String = _line.replace("layer_A", "layer_%s")
					if !_sc_mappings.has("%sc_" + _temp_func_name + "_sc_"):
						_sc_mappings["%sc_" + _temp_func_name + "_sc_"] = ""
					_sc_mappings["%sc_" + _temp_func_name + "_sc_"] += _clean_line
					if _line.begins_with("return"):
						_create_sc_from_next_line = false
						_ignore_new_cases = true
			
			elif !_create_sc_from_next_line:
				_base_string_buffer += _line
	
	_output_file.store_line("const sc_mappings : Dictionary[String, String] = " + JSON.stringify(_sc_mappings))
	
	var _template_file = FileAccess.open("res://addons/CompositeMaterial/shader_composition_template.txt", FileAccess.READ)
	_output_file.store_line("\n")
	for _line in _template_file.get_as_text().split("\n"):
		_output_file.store_line(_line)
		
func _line_is_function_declaration(_line : String):
	if _line.split(" ").size() < 2: return false
	return _line.split(" ")[1].contains("(")
