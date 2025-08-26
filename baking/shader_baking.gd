@tool
extends Node3D

var MDT = MeshDataTool.new()

var previous_face

@onready var ortho_camera = get_node("baking_viewport/viewport/ortho_camera")

signal finished_baking

signal building_material
signal building_mesh
signal baking_albedo
signal baking_roughness
signal baking_metallic
signal baking_normal
signal generating_normal_map

func bake(config : MeshBakingConfig, mesh_instance : MeshInstance3D, base_name : String) -> void:
	var viewport_result = ViewportTexture.new()
	viewport_result.viewport_path = $baking_viewport/viewport.get_path() #We need the absolute path here. This whole window is parented to our main editor so therer's no other way for us to retrieve the absolute path.
	
	building_material.emit()
	
	var material_instance : CompositeMaterial = mesh_instance.get_active_material(0).duplicate(true)
	material_instance.build_material(false)
	#await material_instance.finish_building
	
	building_mesh.emit()
	
	MDT.create_from_surface(mesh_instance.mesh, 0)
	
	for face_idx in MDT.get_face_count():
		var vertex1 = MDT.get_face_vertex(face_idx, 0)
		var v1uv = MDT.get_vertex_uv(vertex1)
		var _v1pos = MDT.get_vertex(vertex1)
		var v1col = MDT.get_vertex_color(vertex1)
		var vertex2 = MDT.get_face_vertex(face_idx, 1)
		var v2uv = MDT.get_vertex_uv(vertex2)
		var _v2pos = MDT.get_vertex(vertex2)
		var v2col = MDT.get_vertex_color(vertex2)
		var vertex3 = MDT.get_face_vertex(face_idx, 2)
		var v3uv = MDT.get_vertex_uv(vertex3)
		var _v3pos = MDT.get_vertex(vertex3)
		var v3col = MDT.get_vertex_color(vertex3)
		
		var _min_x = min(v1uv.x, v2uv.x, v2uv.x)
		var _max_x = max(v1uv.x, v2uv.x, v2uv.x)
		var _min_y = min(v1uv.y, v2uv.y, v2uv.y)
		var _max_y = max(v1uv.y, v2uv.y, v2uv.y)
		
		#Create single face for rendering through viewport
		var isolated_face_points : PackedVector3Array = [Vector3(fmod(v1uv.x - 0.5, 1.0), 0, fmod(v1uv.y - 0.5, 1.0)), Vector3(fmod(v2uv.x - 0.5, 1.0), 0, fmod(v2uv.y - 0.5, 1.0)), Vector3(fmod(v3uv.x - 0.5, 1.0), 0, fmod(v3uv.y - 0.5, 1.0))]
		var isolated_face_uvs : PackedVector2Array = [v1uv, v2uv, v3uv]
		var isolated_face_vc : PackedColorArray = [v1col, v2col, v3col]
		var mesh_arrays = []
		mesh_arrays.resize(Mesh.ARRAY_MAX)
		mesh_arrays[Mesh.ARRAY_VERTEX] = isolated_face_points
		mesh_arrays[Mesh.ARRAY_TEX_UV] = isolated_face_uvs
		mesh_arrays[Mesh.ARRAY_COLOR] = isolated_face_vc
		var isolated_face_mesh = ArrayMesh.new()
		isolated_face_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
		var isolated_face = MeshInstance3D.new()
		isolated_face.mesh = isolated_face_mesh
		$baking_viewport/viewport/faces.add_child(isolated_face)
		isolated_face.set_surface_override_material(0, material_instance)
		
	$baking_viewport/viewport.size = Vector2i(config.resolution_x, config.resolution_y)
	
		#$SubViewportContainer/viewport.get_texture()
		#
		#await RenderingServer.frame_post_draw
		#
		#var face_result = $viewport.get_texture().get_image()
		#face_result.convert(Image.FORMAT_RGBA8)
		#resulting_image.blend_rect(face_result, Rect2i(Vector2i(0, 0), Vector2i(texture_size - Vector2i(1,1))), Vector2i(0,0))
		#
		#viewport_result.get_image().save_jpg("/home/mathias/Desktop/projects/shadowstrider/shadowstrider/output_textures/test.jpg")
		#
		#print("next face")
		#
		#previous_face = isolated_face
	#
	var image_to_be_saved : Image
	
	if config.bake_albedo:
		baking_albedo.emit()
		material_instance.set_shader_parameter("albedo_channel", 0)
		await RenderingServer.frame_post_draw
		image_to_be_saved = $baking_viewport/viewport.get_texture().get_image()
		
		var output_path : String = config.output_path + "/" + base_name + "_albedo.png"
		config.albedo_tex_path = output_path
		save_or_add_to_png(config, output_path, image_to_be_saved)
	
	if config.bake_roughness:
		baking_roughness.emit()
		material_instance.set_shader_parameter("albedo_channel", 1)
		await RenderingServer.frame_post_draw
		image_to_be_saved = $baking_viewport/viewport.get_texture().get_image()
		image_to_be_saved.srgb_to_linear()

		var output_path : String = config.output_path + "/" + base_name + "_roughness.png"
		config.roughness_tex_path = output_path
		save_or_add_to_png(config, output_path, image_to_be_saved)
	
	if config.bake_metallic:
		baking_metallic.emit()
		material_instance.set_shader_parameter("albedo_channel", 2)
		await RenderingServer.frame_post_draw
		image_to_be_saved = $baking_viewport/viewport.get_texture().get_image()
		image_to_be_saved.srgb_to_linear()

		var output_path : String = config.output_path + "/" + base_name + "_metallic.png"
		config.metallic_tex_path = output_path
		save_or_add_to_png(config, output_path, image_to_be_saved)
	
	if config.bake_normal:
		baking_normal.emit()
		material_instance.set_shader_parameter("albedo_channel", 3)
		await RenderingServer.frame_post_draw
		image_to_be_saved = $baking_viewport/viewport.get_texture().get_image()
		#image_to_be_saved.convert(Image.FORMAT_RGB8)
		image_to_be_saved.srgb_to_linear()
		generating_normal_map.emit()
		#generate_blue_channel_from_xy_normal_map(image_to_be_saved) #TODO: Implement way to convert XY (red-green) normal maps to XYZ normal maps for universal compatibility
		
		var output_path : String = config.output_path + "/" + base_name + "_normal.png"
		config.normal_tex_path = output_path
		save_or_add_to_png(config, output_path, image_to_be_saved, true)
	
	for child in $baking_viewport/viewport/faces.get_children():
		child.queue_free()
	
	config.done_baking = true
	
	finished_baking.emit()

func save_or_add_to_png(config : MeshBakingConfig, output_path : String, image_to_be_saved : Image, normal_map : bool = false):
	if FileAccess.file_exists(output_path):
		var old_image : Image = Image.create_empty(1,1,false,Image.FORMAT_RGB8)
		old_image.load(output_path)
		old_image.convert(Image.FORMAT_RGBA8)
		old_image.blend_rect(image_to_be_saved, Rect2i(0, 0, image_to_be_saved.get_width(), image_to_be_saved.get_height()), Vector2i(0,0))
		if !config.enable_alpha:
			old_image.convert(Image.FORMAT_RGB8)
		if normal_map:
			fix_normal_map(old_image)
			#old_image.normal_map_to_xy()
			#old_image.convert(Image.FORMAT_RGB8)
		
		old_image.save_png(output_path)
			
	else:
		if !config.enable_alpha:
			image_to_be_saved.convert(Image.FORMAT_RGB8)
		if normal_map:
			fix_normal_map(image_to_be_saved)
			#image_to_be_saved.normal_map_to_xy()
			#image_to_be_saved.convert(Image.FORMAT_RGB8)
			#generate_blue_channel_from_xy_normal_map(image_to_be_saved)
		image_to_be_saved.save_png(output_path)

func fix_normal_map(input_image : Image): #Not in use, still looking for solution
	print(input_image.get_pixel(0,0))
	for x in input_image.get_width():
		for y in input_image.get_height():
			var color = input_image.get_pixel(x,y)
			
			#if color.b > 0:
				#continue
			
			var color_vector : Vector3 = Vector3(color.r, color.g, 0.0) #Strip blue channel so that the whole map is xy
			
			var blue = sqrt(1 - (color.r*color.r + color.g*color.g)) #Rebuild blue so that blue channel is everywhere
			color_vector.z = blue
			#color_vector = color_vector.normalized()
			input_image.set_pixel(x,y, Color(color_vector.x, color_vector.y, color_vector.z))
	
	#input_image.convert(Image.FORMAT_RGB8)
