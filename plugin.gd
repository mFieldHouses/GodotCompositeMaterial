@tool
extends EditorPlugin

var parameters_plugin

func _enter_tree() -> void:
	add_custom_type("CompositeMaterial", "Material", preload("res://addons/CompositeMaterial/CompositeMaterial.gd"), preload("res://addons/CompositeMaterial/CompositeMaterial.svg"))
	add_custom_type("CompositeMaterialLayer", "Resource", preload("res://addons/CompositeMaterial/CompositeMaterialLayer.gd"), preload("res://addons/CompositeMaterial/CompositeMaterialLayer.svg"))
	
	parameters_plugin = load("res://addons/CompositeMaterial/parameters.gd").new()
	add_inspector_plugin(parameters_plugin)

func _exit_tree() -> void:
	remove_custom_type("CompositeMaterial")
	remove_custom_type("CompositeMaterialLayer")
	add_inspector_plugin(parameters_plugin)
