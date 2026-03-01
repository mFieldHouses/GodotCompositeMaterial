@tool
extends HSplitContainer

var pages : Dictionary[CompositeMaterial, CompositeMaterialBuilderPage]


func edit_material(material : CompositeMaterial) -> void:
	if pages.has(material):
		open_page(material)
	else:
		create_page(material)


func open_page(material : CompositeMaterial) -> void:
	for child in $pages.get_children():
		child.visible = pages[material] == child

func create_page(material : CompositeMaterial) -> void:
	var _new_page = $pages/template_page.duplicate()
	pages[material] = _new_page
	
	$pages.add_child(_new_page)
	
	_new_page.edit_material(material)
	
	var _new_button : Button = $VBoxContainer/Panel/page_buttons/template_button.duplicate()
	_new_button.text = material.resource_path
	_new_button.button_down.connect(open_page.bind(material))
	_new_button.visible = true
	$VBoxContainer/Panel/page_buttons.add_child(_new_button)

	EditorInterface.get_resource_previewer().queue_edited_resource_preview(material, self, "receive_material_preview", {"target_button": _new_button})
	
	open_page(material)


func receive_material_preview(path : String, preview : Texture2D, thumbnail_preview : Texture2D, userdata : Variant) -> void:
	userdata.target_button.icon = thumbnail_preview
