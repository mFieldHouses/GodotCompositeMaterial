@tool
extends EditorPlugin

var parameters_plugin

var previous_property_lists : Array = []

func _enter_tree() -> void:
	add_custom_type("CompositeMaterial", "ShaderMaterial", preload("res://addons/CompositeMaterial/CompositeMaterial.gd"), preload("res://addons/CompositeMaterial/CompositeMaterial.svg"))
	add_custom_type("CompositeMaterialLayer", "Resource", preload("res://addons/CompositeMaterial/CompositeMaterialLayer.gd"), preload("res://addons/CompositeMaterial/CompositeMaterialLayer.svg"))
	
	parameters_plugin = load("res://addons/CompositeMaterial/parameters.gd").new()
	add_inspector_plugin(parameters_plugin)

func _exit_tree() -> void:
	remove_custom_type("CompositeMaterial")
	remove_custom_type("CompositeMaterialLayer")
	add_inspector_plugin(parameters_plugin)

func _process(delta: float) -> void:
	var edited_object = EditorInterface.get_inspector().get_edited_object()
	var composite_material_instance : CompositeMaterial
	if edited_object is MeshInstance3D and edited_object.mesh:
		var edited_object_material = edited_object.get_active_material(0)
		if edited_object_material is CompositeMaterial and edited_object_material.layers.size() != 0:
			composite_material_instance = edited_object_material
	elif edited_object is CompositeMaterial:
		composite_material_instance = edited_object
	
	if composite_material_instance:
		#print_debug("I see a material instance")
		var idx : int = 0
		for layer in composite_material_instance.layers:
			if layer != null:
				#print_debug("layer ", idx, " is not empty")
				var layer_property_name_list = layer.get_property_list()
				var new_property_list_entry = []
				for property_name in layer_property_name_list:
					new_property_list_entry.append(layer.get(property_name.name))
				
				if previous_property_lists.size() >= idx + 1:
					#print(previous_property_lists.size(), " ", idx + 1)
					if new_property_list_entry != previous_property_lists[idx]:
						#print("emit signal")
						layer.emit_changed()
						previous_property_lists[idx] = new_property_list_entry
				else:
					previous_property_lists.append(new_property_list_entry)
				
				idx += 1
