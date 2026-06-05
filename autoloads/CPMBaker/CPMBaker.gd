@tool
extends Node

var allow_baking : bool = true: ## Can be set by your custom scripts to enable/disable baking at your own conditions. For example, you could only allow baking when CPU usage is low.
	set(x):
		if x != allow_baking:
			if x == true:
				if currently_baking.size() < max_simultaneous_processes:
					_bake_mesh(bake_queue.pop_front())
			
		allow_baking = x

const max_simultaneous_processes : int = 10

var bake_queue : Array[CPMMeshInstance3D]
var currently_baking : Array[CPMMeshInstance3D]

var baked_meshes : Array[Mesh] = []

var imagem : ImageM = ImageM.new()

#var compression_thread : Thread = Thread.new()

func _ready() -> void:
	$baking_prompt.visible = false

func request_bake(mesh_instance : CPMMeshInstance3D, force : bool = false) -> void: ## Bakes a [CPMMeshInstance3D]'s CompositeMaterials and replaces the corresponding materials with StandardMaterial3Ds.
	if baked_meshes.has(mesh_instance.mesh) and !force:
		printerr("Mesh ", mesh_instance.mesh, " was already baked, skipping.")
		return
	
	if currently_baking.size() > max_simultaneous_processes or !allow_baking:
		bake_queue.append(mesh_instance)
		return
	
	_bake_mesh(mesh_instance)
	
func _finished_baking(mesh_instance : CPMMeshInstance3D) -> void:
	currently_baking.erase(mesh_instance)
	
	if bake_queue.size() == 0:
		return
	
	if allow_baking:
		_bake_mesh(bake_queue.pop_front())

func _bake_mesh(mesh_instance : CPMMeshInstance3D) -> void:
	print("baking ", mesh_instance)
	
	var viewport : SubViewport = SubViewport.new()
	viewport.own_world_3d = true
	#viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.size = Vector2i(50, 50)
	
	var camera : Camera3D = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 10.0
	camera.current = true
	
	viewport.add_child(camera)
	
	baked_meshes.append(mesh_instance.mesh)
	var baking_mesh_instance = mesh_instance.duplicate()
	baking_mesh_instance.autobake = false
	baking_mesh_instance.mesh = baking_mesh_instance.mesh.duplicate(true)
	
	var surfaces_to_bake : Array[int] = []
	for i in baking_mesh_instance.mesh.get_surface_count():
		if baking_mesh_instance.get_active_material(i) is CompositeMaterial:
			surfaces_to_bake.append(i)
	
	if surfaces_to_bake.size() == 0:
		printerr("Mesh has no CompositeMaterials to bake. Aborting.")
		return
	
	for index : int in surfaces_to_bake:
		var material : CompositeMaterial = baking_mesh_instance.get_active_material(index)
		mesh_instance.original_materials[index] = material
		
		var baking_material : CompositeMaterial = material.duplicate(true)
		baking_material.set_baking_mode(true)
		
		baking_mesh_instance.mesh.surface_set_material(index, baking_material)

	#mesh_instance.add_child(baking_mesh_instance)
	viewport.add_child(baking_mesh_instance)
	add_child(viewport)
	
	var baked_material := ORMMaterial3D.new()
	
	var layers : Array[String] = ["albedo", "roughness", "metallic"]
	
	await RenderingServer.frame_post_draw
	
	var img = viewport.get_texture().get_image() #albedo
	var texture = ImageTexture.create_from_image(img)
	ResourceSaver.save(texture, "res://temp_bake_albedo")
	
	baked_material.albedo_texture = texture
	
	for index : int in surfaces_to_bake:
		baking_mesh_instance.get_active_material(index).set_shader_parameter("baking_channel", 2)
	
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	
	img = viewport.get_texture().get_image() #ORM
	img.srgb_to_linear()
	texture = ImageTexture.create_from_image(img)
	ResourceSaver.save(texture, "res://temp_bake_orm")
	
	baked_material.orm_texture = texture
	
	for index : int in surfaces_to_bake:
		mesh_instance.baked_materials[index] = baked_material
		mesh_instance.mesh.surface_set_material(index, baked_material)
	
	
	#var idx : int = 0
	#for layer_name : String in layers:
		#for index : int in surfaces_to_bake:
			#baking_mesh_instance.get_active_material(index).set_shader_parameter("baking_channel", idx)
		#
		#await RenderingServer.frame_post_draw
		#await RenderingServer.frame_post_draw
		#
		#var img = viewport.get_texture().get_image()
		#var texture = ImageTexture.create_from_image(img)
		#
		#baked_material.set(layer_name + "_texture", texture)
		#
		#idx += 1
	
	for index : int in surfaces_to_bake:
		mesh_instance.baked_materials[index] = baked_material
	
	viewport.queue_free()

func _bake_imported_gltf_model(path : String) -> void:
	var model : Node3D = load(path).instantiate()
	
	var viewport : SubViewport = SubViewport.new()
	viewport.own_world_3d = true
	
	#viewport.world_3d = World3D.new()
	#viewport.world_3d.environment = preload("res://addons/CompositeMaterial/resources/baking_background.tres")
	
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.size = Vector2i(256, 256)
	
	var camera : Camera3D = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 10.0
	camera.current = true
	
	viewport.add_child(camera)
	viewport.add_child(model)
	
	var meshes_to_bake : Dictionary[MeshInstance3D, Array] = {}
	
	for node : Node in get_children_recursive(model):
		if node is not MeshInstance3D:
			continue
		
		var surfaces_to_bake : Array[int] = []
		for i in node.mesh.get_surface_count():
			if node.get_active_material(i) is CompositeMaterial:
				surfaces_to_bake.append(i)
	
		if surfaces_to_bake.size() == 0:
			printerr("Mesh has no CompositeMaterials to bake. Ignoring.")
			return
	
		for index : int in surfaces_to_bake:
			var material : CompositeMaterial = node.get_active_material(index)
			material.set_baking_mode(true)
			
			#node.mesh.surface_set_material(index, baking_material)
		
		meshes_to_bake[node as MeshInstance3D] = surfaces_to_bake
		print(node, ": ", node.mesh.surface_get_material(0), " ", node.mesh.surface_get_material(0).baking_mode)
		
	add_child(viewport)
	
	print(meshes_to_bake)
	
	var baked_material := ORMMaterial3D.new()
	
	var layers : Array[String] = ["albedo", "roughness", "metallic"]
	
	for mesh_instance in meshes_to_bake:
		print("set baking channel on ", mesh_instance, " to 0")
		var surfaces_to_bake = meshes_to_bake[mesh_instance]
		for index : int in surfaces_to_bake:
			mesh_instance.get_active_material(index).set_shader_parameter("baking_channel", 0)
	
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	
	var img = viewport.get_texture().get_image().duplicate() #albedo
	imagem.expand_image_boundaries(img, 2)
	img.compress(Image.COMPRESS_S3TC)
	var texture = ImageTexture.create_from_image(img)
	
	baked_material.albedo_texture = texture
	
	for mesh_instance in meshes_to_bake:
		print("set baking channel on ", mesh_instance, " to 1")
		var surfaces_to_bake = meshes_to_bake[mesh_instance]
		for index : int in surfaces_to_bake:
			mesh_instance.get_active_material(index).set_shader_parameter("baking_channel", 1)
	
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	
	img = viewport.get_texture().get_image().duplicate() #Normal map
	img.srgb_to_linear()
	imagem.expand_image_boundaries(img, 2)
	img.compress(Image.COMPRESS_BPTC)
	texture = ImageTexture.create_from_image(img)
	
	baked_material.normal_texture = texture
	baked_material.normal_enabled = true
	
	for mesh_instance in meshes_to_bake:
		print("set baking channel on ", mesh_instance, " to 2")
		var surfaces_to_bake = meshes_to_bake[mesh_instance]
		for index : int in surfaces_to_bake:
			mesh_instance.get_active_material(index).set_shader_parameter("baking_channel", 2)
	
	
	
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	
	img = viewport.get_texture().get_image().duplicate() #ORM
	imagem.expand_image_boundaries(img, 2)
	img.srgb_to_linear()
	img.compress(Image.COMPRESS_S3TC)
	texture = ImageTexture.create_from_image(img)
	
	baked_material.orm_texture = texture
	var material_path : String = "res://addons/CompositeMaterial/baked_materials/" + path.trim_prefix("res://") + "_baked.tres"
	ResourceSaver.save(baked_material, material_path)
	
	
	for mesh in meshes_to_bake:
		var surfaces_to_bake = meshes_to_bake[mesh]
		
		for index : int in surfaces_to_bake:
			var material : CompositeMaterial = mesh.get_active_material(index)
			material.set_baking_mode(false)
	
	
	var import_file : ConfigFile = ConfigFile.new()
	import_file.load(path + ".import")
	
	var _subresources = import_file.get_value("params", "_subresources")
	
	_subresources["cpm/baked"] = true
	
	for external_material : String in _subresources.materials:
		var config : Dictionary = _subresources.materials[external_material]
		config.erase("use_external/path")
		config["cpm/original_material_path"] = config["use_external/fallback_path"]
		config["use_external/fallback_path"] = material_path
		
		print(config)
	
	import_file.set_value("params", "_subresources", _subresources)
	import_file.save(path + ".import")
	
	EditorInterface.get_resource_filesystem().reimport_files(PackedStringArray([path]))
	
	viewport.queue_free()

func _revert_imported_gltf_model(path : String) -> void:
	var import_file : ConfigFile = ConfigFile.new()
	import_file.load(path + ".import")
	
	var _subresources = import_file.get_value("params", "_subresources")
	
	_subresources["cpm/baked"] = false
	
	for external_material : String in _subresources.materials:
		var config : Dictionary = _subresources.materials[external_material]
		
		if !config.has("cpm/original_material_path"):
			printerr("Cannot revert material as there is no original material path entry.")
			continue
		
		config.erase("use_external/path")
		config["use_external/fallback_path"] = config["cpm/original_material_path"]
	
	import_file.set_value("params", "_subresources", _subresources)
	import_file.save(path + ".import")
	
	EditorInterface.get_resource_filesystem().reimport_files(PackedStringArray([path]))
	
	

func get_children_recursive(node : Node) -> Array[Node]:
	var _result : Array[Node] = []
	var _children_to_be_checked : Array[Node] = []
	
	for _child in node.get_children():
		_children_to_be_checked.append(_child)
	
	while _children_to_be_checked.size() > 0:
		var _child_to_check : Node = _children_to_be_checked[0]
		for _subchild in _child_to_check.get_children():
			_children_to_be_checked.append(_subchild)
		
		_result.append(_child_to_check)
		_children_to_be_checked.erase(_child_to_check)
	
	return _result


func bake_popup(model : CPMModel) -> void:
	$baking_prompt.bake_popup(model)
