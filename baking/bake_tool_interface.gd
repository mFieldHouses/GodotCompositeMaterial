@tool
extends Panel

var model_name : String
var model

var mesh_configs : Dictionary = {}

var currently_edited_config : MeshBakingConfig = null
var currently_copied_config : MeshBakingConfig = null

var pre_bake_error_proceed : bool = false
signal pre_bake_error_proceed_signal

@onready var mesh_config_ui = get_node("bake_tool_interface/VBoxContainer/HSplitContainer/mesh_config_scroll/mesh_config/Mesh/VBoxContainer")
@onready var mesh_list_ui = get_node("bake_tool_interface/VBoxContainer/HSplitContainer/mesh_list/mesh_list_scroll/VBoxContainer")
@onready var status_label = get_node("bake_tool_interface/VBoxContainer/status")

var generate_model : bool = false
var generation_mode : int = 0 #0 is placeholder, 1 is enabled meshes, 2 is all meshes
var file_format : int = 0 #0 is .tscn, 1 is .gltf
var model_output_path : String = "":
	set(x):
		model_output_path = x
		%General/VBoxContainer/output_model_path/model_output_path.text = x

func setup():
	var editor_settings = EditorInterface.get_editor_settings()
	var new_stylebox = StyleBoxFlat.new()
	new_stylebox.bg_color = editor_settings.get_setting("interface/theme/base_color").darkened(0.3)
	add_theme_stylebox_override("panel", new_stylebox)

	var new_file_dialog = EditorFileDialog.new()
	new_file_dialog.title = "Open model to bake"
	new_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	new_file_dialog.set_filters(PackedStringArray(["*.gltf, *.fbx, *.obj ; 3D Models","*.tscn ; Godot Scenes"]))
	
	add_child(new_file_dialog)
	new_file_dialog.file_selected.connect(open_model)
	new_file_dialog.canceled.connect(func cancel(): get_parent().get_parent().queue_free())
	new_file_dialog.popup_centered(Vector2i(800,600))
	
	get_node("bake_tool_interface/VBoxContainer/HSplitContainer/mesh_list").mesh_selected.connect(select_mesh)
	
	%General/VBoxContainer/generate_model.toggled.connect(func x(x): generate_model = x)
	%General/VBoxContainer/generation_mode.get_popup().id_pressed.connect(func x(x): generation_mode = x)

func open_model(path : String):
	model = load(path).instantiate()
	model_name = model.name
	get_parent().title = get_parent().title + ": " + path.get_file() #Sets the file name in the window title
	$bake_tool_interface/VBoxContainer/HSplitContainer/mesh_list.set_model_name(path.get_file())
	
	for child in model.get_children():
		if child is MeshInstance3D:
			var material_for_mesh = child.get_active_material(0)
			var new_item : HBoxContainer = $bake_tool_interface/VBoxContainer/HSplitContainer/mesh_list/mesh_list_scroll/VBoxContainer/empty.duplicate()
			new_item.name = child.name
			new_item.visible = true
			$bake_tool_interface/VBoxContainer/HSplitContainer/mesh_list/mesh_list_scroll/VBoxContainer.add_child(new_item)
			
			var new_mesh_config = MeshBakingConfig.new()
			new_mesh_config.source_mesh_name = child.name
			new_mesh_config.enabled = child.visible
			new_item.get_node("checkbox").button_pressed = child.visible
			if material_for_mesh is not ShaderMaterial:
				new_mesh_config.supported = false
				new_mesh_config.enabled = false
				new_item.get_node("checkbox").button_pressed = false
				new_item.get_node("checkbox").disabled = true
			
			new_item.get_node("checkbox").toggled.connect((func x(state : bool, mesh_name : String): mesh_configs[mesh_name].enabled = state).bind(child.name))
			
			mesh_configs.get_or_add(child.name)
			mesh_configs[child.name] = new_mesh_config
			
			update_mesh_label(new_mesh_config)
			
			var mesh = child.duplicate()
			$bake_tool_interface/VBoxContainer/HSplitContainer/mesh_config_scroll/mesh_config/Mesh/VBoxContainer/header/SubViewportContainer/preview_viewport/meshes.add_child(mesh)
			mesh.position = Vector3(0,0,0)
			mesh.visible = false
		
	$bake_tool_interface/VBoxContainer/HSplitContainer/mesh_list/mesh_list_scroll/VBoxContainer/empty.queue_free()
	
	get_node("bake_tool_interface/VBoxContainer/HSplitContainer/mesh_list").setup()
	
	select_mesh(mesh_configs.keys()[0])
	
func select_mesh(mesh_name):
	save_config()
	load_config(mesh_configs[mesh_name])
	update_num_selected()
	show_mesh_in_viewport(mesh_name)
	%General.visible = false #Switch from General tab to Mesh tab if General tab was being viewed. TabContainer automatically takes care of this.

func show_mesh_in_viewport(mesh_name):
	for mesh in $bake_tool_interface/VBoxContainer/HSplitContainer/mesh_config_scroll/mesh_config/Mesh/VBoxContainer/header/SubViewportContainer/preview_viewport/meshes.get_children():
		if mesh.name == mesh_name:
			mesh.visible = true
		else:
			mesh.visible = false

func load_config(config : MeshBakingConfig):
	currently_edited_config = config
	var apply_config_value_to_node = func x(value, node): if node is LineEdit or node is Label: node.text = value elif node is CheckBox or node is CheckButton: node.button_pressed = value elif node is SpinBox: node.value = value
	
	
	for property in config.get_property_list():
		for child in mesh_config_ui.get_children():
			if child.name == property.name:
				apply_config_value_to_node.call(config.get(property.name), child)
			elif child.has_node(property.name):
				apply_config_value_to_node.call(config.get(property.name), child.get_node(property.name))
		
		if mesh_config_ui.get_node("header/VBoxContainer").has_node(property.name):
			apply_config_value_to_node.call(config.get(property.name), mesh_config_ui.get_node("header/VBoxContainer").get_node(property.name))
	
	if !config.supported:
		mesh_config_ui.get_node("header/VBoxContainer/warning_unbakeable").visible = true
	else:
		mesh_config_ui.get_node("header/VBoxContainer/warning_unbakeable").visible = false
	
func save_config(test = ""):
	
	if currently_edited_config:
		var config = currently_edited_config
		
		var save_config_value_from_node = \
			func x(value, node): 
				var target_property_name = node.name 
				if node is LineEdit: 
					config.set(target_property_name, node.text)
				elif node is CheckBox or node is CheckButton:
					config.set(target_property_name, node.button_pressed)
				elif node is SpinBox:
					config.set(target_property_name, node.value)
		
		for property in config.get_property_list():
			for child in mesh_config_ui.get_children():
				if child.name == property.name and !child.has_meta("ignore"):
					save_config_value_from_node.call(config.get(property.name), child)
				elif child.has_node(property.name):
					save_config_value_from_node.call(config.get(property.name), child.get_node(property.name))
			
			if mesh_config_ui.get_node("header/VBoxContainer").has_node(property.name):
				save_config_value_from_node.call(config.get(property.name), mesh_config_ui.get_node("header/VBoxContainer").get_node(property.name))
			
		update_mesh_label(config)

func update_mesh_label(config : MeshBakingConfig):
	get_node("bake_tool_interface/VBoxContainer/HSplitContainer/mesh_list/mesh_list_scroll/VBoxContainer").get_node(config.source_mesh_name).get_node("label/text").update_name(config.source_mesh_name, config.output_name, config.supported)

func update_all_mesh_names():
	for config in mesh_configs:
		config = mesh_configs[config]
		update_mesh_label(config)

func copy_property_to_all(property_name : String):
	for config in mesh_configs:
		config = mesh_configs[config]
		config.set(property_name, currently_edited_config.get(property_name))

func copy_property_to_enabled(property_name : String, state : bool):
	for mesh_name in mesh_configs:
		var config = mesh_configs[mesh_name]
		if config.enabled == state:
			config.set(property_name, currently_edited_config.get(property_name))


func copy_current_config():
	currently_copied_config = currently_edited_config

func paste_onto_current_config():
	currently_edited_config.paste(currently_copied_config)
	load_config(currently_edited_config)
	update_mesh_label(currently_edited_config)

func copy_current_config_to_all():
	copy_current_config()
	
	for config in mesh_configs:
		mesh_configs[config].paste(currently_copied_config)
	
	update_all_mesh_names()

func update_num_selected():
	var num_selected : int = 0
	for child in mesh_list_ui.get_children():
		num_selected += int(child.get_node("checkbox").button_pressed)
	
	if num_selected == 0:
		$bake_tool_interface/VBoxContainer/option_buttons/bake.disabled = true
	else:
		$bake_tool_interface/VBoxContainer/option_buttons/bake.disabled = false
	
	$bake_tool_interface/VBoxContainer/option_buttons/num_selected.text = str(num_selected) + " selected for baking"

func _on_bake_button_down() -> void:
	save_config()
	
	var meshes_to_bake : Array[MeshBakingConfig] = [] #Array of configs of meshes that ought to be baked
	
	for mesh_name in mesh_configs:
		var config = mesh_configs[mesh_name]
		if config.enabled:
			meshes_to_bake.append(config)
	
	var errors : Array = []
	var can_proceed : bool = true
	
	#First pass we check if everything is ready to bake
	for config in meshes_to_bake:
		if config.output_path == "":
			var error_string : String = config.source_mesh_name + ": Mesh doesn't have output path set. Textures will be saved to res://."
			errors.append(error_string)
	
	#Check if all configs for generated model are set correctly
	if generate_model:
		if model_output_path == "":
			errors.append("Generated model doesn't have output path set. Model will be saved to res://.")
		if generation_mode == 0:
			errors.append("Generated model doesn't have generation mode set. Cannot proceed.")
			can_proceed = false
		
	if errors.size() != 0:
		pre_bake_error_screen(errors, can_proceed)
		await pre_bake_error_proceed_signal
		
		if pre_bake_error_proceed == false:
			return
	
	#Second pass, when everything is OK we actually bake everything
	
	for config in meshes_to_bake:
		var output_texture_name : String = ""
		if config.output_name == "":
			output_texture_name = config.source_mesh_name
		else:
			output_texture_name = config.output_name
		
		$baking.building_material.connect(func x(): status_label.text = "(" + config.source_mesh_name + "): Building CompositeMaterial...")
		$baking.building_mesh.connect(func x(): status_label.text = "(" + config.source_mesh_name + "): Building mesh...")
		$baking.baking_albedo.connect(func x(): status_label.text = "(" + config.source_mesh_name + "): Baking albedo...")
		$baking.baking_roughness.connect(func x(): status_label.text = "(" + config.source_mesh_name + "): Baking roughness...")
		$baking.baking_metallic.connect(func x(): status_label.text = "(" + config.source_mesh_name + "): Baking metallic...")
		$baking.baking_normal.connect(func x(): status_label.text = "(" + config.source_mesh_name + "): Baking normal...")
		$baking.generating_normal_map.connect(func x(): status_label.text = "(" + config.source_mesh_name + "): Generating additional normal data...")
		$baking.finished_baking.connect(func x(): status_label.text = "Done baking!"; print("finsihed baking mesh"))
		
		$baking.bake(config, model.get_node(config.source_mesh_name), output_texture_name)
		
		await $baking.finished_baking
	
	var editor_file_system = EditorInterface.get_resource_filesystem()
	editor_file_system.scan()
	await editor_file_system.filesystem_changed
	
	if generate_model:
		save_model(meshes_to_bake)
	
	get_node("bake_tool_interface/VBoxContainer/option_buttons/cancel").text = "Close"

func pre_bake_error_screen(errors : Array, can_proceed : bool): ##Returns whether the baker should proceed (true) or cancel (false). This value is stored in pre_bake_error_proceed
	var new_dialog = ConfirmationDialog.new()
	new_dialog.title = "Warnings"
	new_dialog.ok_button_text = "Proceed"
	new_dialog.cancel_button_text = "Go Back"
	
	var text : String
	for error in errors:
		text = text + error + "\n"
	
	new_dialog.dialog_text = text
	add_child(new_dialog)
	new_dialog.popup_centered(Vector2i(300,200))
	new_dialog.canceled.connect(func(): pre_bake_error_proceed = false; pre_bake_error_proceed_signal.emit())
	new_dialog.confirmed.connect(func(): pre_bake_error_proceed = true; pre_bake_error_proceed_signal.emit())
	
	new_dialog.get_ok_button().disabled = !can_proceed
	
	await pre_bake_error_proceed_signal

func save_model(mesh_configs : Array[MeshBakingConfig]): ##Saves a collection of meshes in a .tscn file
	var scene = PackedScene.new()
	
	for mesh_config in mesh_configs:
		var mesh_to_save : MeshInstance3D = model.get_node(mesh_config.source_mesh_name).duplicate()
		
		var new_material : StandardMaterial3D = StandardMaterial3D.new()
		if mesh_config.bake_albedo:
			new_material.albedo_texture = load(mesh_config.albedo_tex_path)
		if mesh_config.bake_roughness:
			new_material.roughness_texture = load(mesh_config.roughness_tex_path)
		if mesh_config.bake_metallic:
			new_material.metallic_texture = load(mesh_config.metallic_tex_path)
		if mesh_config.bake_normal:
			new_material.normal_texture = load(mesh_config.normal_tex_path)
		mesh_to_save.set_surface_override_material(0, new_material)
		
		scene.pack(mesh_to_save)
	
	ResourceSaver.save(scene, model_output_path)

func _on_browse_path_button_down() -> void:
	var new_file_dialog = EditorFileDialog.new()
	new_file_dialog.title = "Select texture output directory"
	new_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	#new_file_dialog.set_filters(PackedStringArray(["*.gltf, *.fbx, *.obj ; 3D Models","*.tscn ; Godot Scenes"]))
	
	add_child(new_file_dialog)
	new_file_dialog.dir_selected.connect(func x(path): currently_edited_config.output_path = path; load_config(currently_edited_config))
	new_file_dialog.canceled.connect(func cancel(): new_file_dialog.queue_free())
	new_file_dialog.popup_centered(Vector2i(800,600))

func _on_browse_output_model_path_button_down() -> void:
	var new_file_dialog = EditorFileDialog.new()
	new_file_dialog.title = "Save model"
	new_file_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	new_file_dialog.set_filters(PackedStringArray(["*.tscn ; Godot Scene"]))
	
	add_child(new_file_dialog)
	new_file_dialog.file_selected.connect(func x(path): model_output_path = path)
	new_file_dialog.canceled.connect(func cancel(): new_file_dialog.queue_free())
	new_file_dialog.popup_centered(Vector2i(800,600))
