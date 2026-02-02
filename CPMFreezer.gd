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

func freeze_cpm(material : CompositeMaterial) -> void:
	var first_order_functions : Array[String]
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
		
		var _idx : int = 0
		var _depth : int = 0
		var _found_function_end : bool = false
		var _found_function_signature : bool = false
		while _found_function_end == false:
			if _shader_code[_idx_in_code + _idx] == "{":
				_depth += 1
			elif _shader_code[_idx_in_code + _idx] == "}":
				_depth -= 1
				if _depth == 0:
					_found_function_end = true
			
			if _shader_code[_idx_in_code + _idx] == ")" and _found_function_signature == false:
				_full_function_signature = _shader_code.substr(_idx_in_code, _idx + 1)
				_found_function_signature = true
			
			_idx += 1
		
		_shader_code = _shader_code.erase(_idx_in_code, _idx)
		_shader_code = _shader_code.insert(_idx_in_code, _full_function_signature + " {return 0.0;}")
	
	material.unfrozen_shader = material.shader
	var _sh := Shader.new()
	_sh.code = _shader_code
	material.shader = _sh
	
func unfreeze_material(material : FrozenCompositeMaterial) -> void:
	_set_currently_selected_node_material(material.source_composite_material)

func _set_currently_selected_node_material(material : Material) -> void:
	var _node = EditorInterface.get_selection().get_selected_nodes()[0]
	
	if _node is MeshInstance3D:
		_node.mesh.surface_set_material(0, material)
		
		
		
