@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("CompositeMaterial", "Material", preload("res://addons/CompositeMaterial/CompositeMaterial.gd"), preload("res://addons/CompositeMaterial/CompositeMaterial.svg"))
	add_custom_type("CompositeMaterialLayer", "Resource", preload("res://addons/CompositeMaterial/CompositeMaterialLayer.gd"), preload("res://addons/CompositeMaterial/CompositeMaterialLayer.svg"))


func _exit_tree() -> void:
	remove_custom_type("CompositeMaterial")
	remove_custom_type("CompositeMaterialLayer")
