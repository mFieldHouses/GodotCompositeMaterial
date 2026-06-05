@tool
extends Node

##Autoload that manages effect shapes and exposes them to shaders using global uniforms and textures.

# Code for interfacing with RenderingDevice was taken from
# https://github.com/godotengine/godot-proposals/discussions/9553#discussioncomment-15599036

var materials : Dictionary[ShaderMaterial, Dictionary] = {
	
}

var rendering_device : RenderingDevice
var texture_rid : RID

func _ready() -> void:
	rendering_device = RenderingServer.get_rendering_device()
	
	for material : ShaderMaterial in materials:
		_generate_material_linemaps(material)
	#if Engine.is_editor_hint():
		#RenderingServer.call_on_render_thread(_initialize_rendering)

func _generate_material_linemaps(material : ShaderMaterial) -> void:
	if !materials.has(material):
		printerr("This material was not registered with CPMLineMapManager. No linemaps will be generated for it.")
		return
	
	var images : Array[Image] = []
	
	for instance : CPMMeshInstance3D in materials[material].keys():
		var mesh = instance.mesh
		if instance.mesh is PrimitiveMesh:
			var st := SurfaceTool.new()
			st.create_from(instance.mesh, 0)
			mesh = st.commit()
			
		var mdt := MeshDataTool.new()
		mdt.create_from_surface(mesh, 0)
		
		var position_to_vertices_map : Dictionary[Vector3, Array]
		
		# Generate map of vertex duplicates. If there's more than one vertex inhabiting a single quantified position,
		# all vertices will point to the first found vertex index that inhabits that position.
		
		print("mapping duplicate vertices...")
		
		for i in mdt.get_vertex_count():
			var vertex_pos : Vector3 = mdt.get_vertex(i)
			var vertex_pos_snapped = snapped(vertex_pos, Vector3(0.001, 0.001, 0.001))
			
			if !position_to_vertices_map.has(vertex_pos_snapped):
				position_to_vertices_map[vertex_pos_snapped] = []
			
			position_to_vertices_map[vertex_pos_snapped].append(i)
		
		var vertex_duplicates_map : Dictionary[int, int] = {}
		
		for pos : Vector3 in position_to_vertices_map:
			var vertex_array = position_to_vertices_map[pos]
			for vertex_idx : int in vertex_array:
				vertex_duplicates_map[vertex_idx] = vertex_array[0]
		
		print("done mapping duplicate vertices\n")
		
		# Generate list of excluded edges. We mainly look at vertex colors for both points in every edge to determine
		# whether it needs to be excluded.
		
		var included_edges : Array[Array] = []
		var excluded_edges : Array[Array] = []
		var checked_edges : Array[Array] = []
		
		print("building include and exclude lists...")
		
		for edge_idx : int in mdt.get_edge_count():
			var v1 : int = vertex_duplicates_map[mdt.get_edge_vertex(edge_idx, 0)]
			var v2 : int = vertex_duplicates_map[mdt.get_edge_vertex(edge_idx, 1)]
			
			var edge : Array[int] = [v1, v2]
			
			if checked_edges.has(edge):
				#print("already found edge")
				continue
			
			checked_edges.append(edge)
			edge.reverse()
			checked_edges.append(edge)
			
			if ((mdt.get_vertex_color(v1).g == 1.0 and mdt.get_vertex_color(v2).g == 0.0) and (mdt.get_vertex_color(v1).b == 0.0 and mdt.get_vertex_color(v2).b == 1.0)) or ((mdt.get_vertex_color(v1).g == 0.0 and mdt.get_vertex_color(v2).g == 1.0) and (mdt.get_vertex_color(v1).b == 1.0 and mdt.get_vertex_color(v2).b == 0.0)):
				excluded_edges.append(edge)
				edge.reverse()
				excluded_edges.append(edge)
				continue
			
			if !(mdt.get_vertex_color(v1).r == 1.0 and mdt.get_vertex_color(v2).r == 1.0):
				excluded_edges.append(edge)
				edge.reverse()
				excluded_edges.append(edge)
				continue
			
			included_edges.append(edge)
			edge.reverse()
			included_edges.append(edge)
			
			#print("did not exclude edge: ", edge)
		
		print(array_unique(excluded_edges).size(), " edges were excluded")
		print(array_unique(included_edges).size(), " edges were included")
		print("(includes duplicate reversed edges)\n")
		
		var scanned_edges : Array[Array]
		var seed_edges : Array[Array] = []
		
		var edge_strings : Array[Array] = []
		
		print("looking for starting edge...")
		for edge_idx : int in mdt.get_edge_count():
			var v1 : int = vertex_duplicates_map[mdt.get_edge_vertex(edge_idx, 0)]
			var v2 : int = vertex_duplicates_map[mdt.get_edge_vertex(edge_idx, 1)]
			
			var edge : Array[int] = [v1, v2]
			
			if included_edges.has(edge):
				seed_edges.append(edge)
				print("\tfound new seed edge: ", edge)
			else:
				print("\tedge was not included: ", edge)
		
		print("\n")
		
		var iter : int = 0
		while seed_edges.size() > 0:
			iter += 1
			if iter > 1000:
				printerr("timeout")
				break 
			
			print("\npicking new seed edge")
			
			var iter_edge : Array[int] = seed_edges.pop_front()
			
			if scanned_edges.has(iter_edge):
				print("\tthis edge has already been scanned, continuing")
				continue
			
			print("now iterating from seed edge ", iter_edge)
			
			var edge_string : Array[Array] = []
			
			var iter2 : int = 0
			while iter_edge.size() != 0:
				iter += 1
				if iter > 500:
					printerr("\ttimeout2")
					break 
				
				var end_vertex : int = iter_edge[1]
				var available_edge_indices : PackedInt32Array = mdt.get_vertex_edges(end_vertex)
				var available_edges : Array[Array] = []
				
				print("\titerating from iter_edge ", iter_edge)
				
				
				
				var _reverse_edge = iter_edge.duplicate(true)
				_reverse_edge.reverse()
				
				if scanned_edges.has(iter_edge) and scanned_edges.has(_reverse_edge):
					print("\t\titer_edge was already scanned. Stopping iteration")
					iter_edge = []
					continue
				
				scanned_edges.append(iter_edge)
				scanned_edges.append(_reverse_edge)
				
				edge_string.append(iter_edge)
				
				for available_edge_idx : int in available_edge_indices:
					var v1 : int = vertex_duplicates_map[mdt.get_edge_vertex(available_edge_idx, 0)]
					var v2 : int = vertex_duplicates_map[mdt.get_edge_vertex(available_edge_idx, 1)]
					
					var edge : Array[int] = [v1, v2]
					var edge_reverse = edge.duplicate()
					edge_reverse.reverse()
					
					if !included_edges.has(edge):
						#print("edge was not included")
						continue
					
					if edge == iter_edge or edge_reverse == iter_edge:
						#print("Same as iter_edge")
						continue
					
					if edge[0] == iter_edge[1]:
						available_edges.append(edge)
					else:
						available_edges.append(edge_reverse)
				
				if available_edges.size() == 0:
					print("\t\tno available edges. Stopping iteration")
					iter_edge = []
					continue
				
				print("\t\tavailable edges: ", available_edges)
				
				iter_edge = available_edges.pop_front()
			
			edge_strings.append(edge_string)
		
		print("\nattempting to interconnect edge strings...")
		
		var reverse_edge_string : Callable =\
			func(edge_string : Array[Array]) -> void:
				edge_string.reverse()
				
				for edge : Array in edge_string:
					edge.reverse()
		
		var finished : bool = false
		var _iter : int = 0
		while !finished:
			_iter += 1
			if _iter > 100:
				printerr("timeout")
				break
			
			var endpoints : Dictionary[int, Array] = {}
			
			var string_idx : int = -1
			for edge_string : Array[Array] in edge_strings:
				string_idx += 1
				if edge_string.size() == 3:
					if edge_string[0][0] == edge_string[2][1]:
						print("\tfound a triangle, excluding this one")
						edge_strings.erase(edge_string)
						continue
				
				var begin : int = edge_string[0][0]
				var end : int = edge_string.back().back()
				
				if !endpoints.has(begin):
					endpoints[begin] = []
				if !endpoints.has(end):
					endpoints[end] = []
				
				endpoints[begin].append(string_idx)
				endpoints[end].append(string_idx)
			
			print("\n", edge_strings.size(), " edge strings:")
			print(edge_strings)
			
			print("\nendpoints: ", endpoints)
			
			finished = true
			for point : int in endpoints:
				if endpoints[point].size() >= 2:
					finished = false
					
					var edge_string_1_idx : int = endpoints[point][0]
					var edge_string_2_idx : int = endpoints[point][1]
					
					var og_edge_string_1 : Array[Array] = edge_strings[edge_string_1_idx]
					var og_edge_string_2 : Array[Array] = edge_strings[edge_string_2_idx]
					
					var edge_string_1 : Array[Array] = og_edge_string_1.duplicate()
					var edge_string_2 : Array[Array] = og_edge_string_2.duplicate()
					
					var switch : bool = false
					var reverse : int = 0
					if edge_string_1[0][0] == point && edge_string_2[0][0] == point:
						reverse = -1
					elif edge_string_1.back()[1] == point && edge_string_2.back()[1] == point:
						reverse = 1
					elif edge_string_1.back()[1] != edge_string_2[0][0]:
						switch = true
					
					print("\tcan interconnect edge strings ", edge_string_1, " and ", edge_string_2)
					print("\tneed to reverse: ", reverse)
					
					match reverse:
						1:
							print("\t\treverse second string")
							reverse_edge_string.call(edge_string_2)
						-1:
							print("\t\treverse first string")
							reverse_edge_string.call(edge_string_1)
					
					if switch:
						print("\t\tswitch places")
						var _old_1 = edge_string_1
						edge_string_1 = edge_string_2
						edge_string_2 = _old_1
					
					print("\tfixed edge strings: ", edge_string_1, " and ", edge_string_2)
					
					var merged_string : Array[Array] = edge_string_1.duplicate()
					merged_string.append_array(edge_string_2)
					
					print("\tresult: ", merged_string)
					
					edge_strings.append(merged_string)
					
					edge_strings.erase(og_edge_string_1)
					edge_strings.erase(og_edge_string_2)
					
					break;
		
		print("done")
		
		#region comment
		#var vertex_list : Array = []
		#
		#var checked_edges : Array[Array] = []
		#
		#var previous_edge_idx : int = 0
		#var starting_vertex_idx : int = 0
		#var previous_vertex_idx : int = 0
		#var current_vertex_idx : int = 0
		#var current_edge_string : int = 0
		#

		#var selected_edges : Array[Array] = []
		#
		#for edge_idx : int in mdt.get_edge_count():
			#var v1 = vertex_duplicates_map[mdt.get_edge_vertex(edge_idx, 0)]
			#var v2 = vertex_duplicates_map[mdt.get_edge_vertex(edge_idx, 1)]
			#
			#if checked_edges.has([v1, v2]) or checked_edges.has([v2, v1]):
				#print("already passed this edge")
				#continue
		#
			#checked_edges.append([v1, v2])
			#
			#if (mdt.get_vertex_color(v1).g == 1.0 and mdt.get_vertex_color(v2).g == 1.0) or (mdt.get_vertex_color(v1).b == 1.0 and mdt.get_vertex_color(v2).b == 1.0):
				#print("excluding edge")
				#continue
			#
			#if mdt.get_vertex_color(v1).r == 1.0 and mdt.get_vertex_color(v2).r == 1.0:
				#print("found edge with vertex color")
				#selected_edges.append([v1, v2])
		#
		#print(selected_edges) # Here we have a list of all edges of which both points are colored white
		#
	
		#
		#var edge_strings : Array[Array] = []
		#
		#var iter : int = 0
		#var edge = selected_edges[0]
		#while selected_edges.size() > 0:
			#iter += 1
			#if iter > 50:
				#print("timeout")
				#break
			#
			#if edge == null:
				#print("done")
				#break
			#
			#print("\nchecking edge ", edge)
			#edge_strings.append(edge)
			#selected_edges.erase(edge)
			#
			#for edge2 : Array in selected_edges:
				#if edge2 == edge:
					#continue
				#
				##print("comparing to ", edge2)
				#if edge2[0] == edge[1]:
					#print("found connecting edge: ", edge2)
					#edge = edge2.duplicate()
					#break
				#
				#edge2.reverse()
				#
				#if edge2[0] == edge[1]:
					#print("found connecting edge: ", edge2)
					#edge = edge2.duplicate()
					#break
			#
			#selected_edges.erase(edge)
		#
		#print(edge_strings) # Here we have a list of all selected edges in proper order
		#
		var temp_strings : Array = []
		
		for edge_string : Array[Array] in edge_strings:
			var string : Array = []
			temp_strings.append(string)
			
			for edge in edge_string:
				if edge == edge_string[0]:
					string.append_array(edge)
				else:
					string.append(edge[1])
		
		#temp_string.append(temp_string[0])
		
		print(temp_strings)
		
		var location_strings : Array[Array]
		
		for string : Array in temp_strings:
			var position_string : Array = []
			location_strings.append(position_string)
			for idx : int in string:
				position_string.append(mdt.get_vertex(idx))
		
		print(location_strings)
		
		var mesh_aabb : AABB = mesh.get_aabb()
		print("AABB: ", mesh_aabb)
		var resolution : int = 16
		
		var cells : Array[Array] = [] # 3D array
		var cell_size : Vector3 = mesh_aabb.size / 16.0
		
		for x_step in resolution:
			cells.append([])
			for y_step in resolution:
				cells[x_step].append([])
				for z_step in resolution:
					var cell : Array = []
					cells[x_step][y_step].append(cell)
					
					var local_aabb : AABB = AABB(Vector3(cell_size.x * x_step + mesh_aabb.position.x, cell_size.y * y_step + mesh_aabb.position.y, cell_size.z * z_step + mesh_aabb.position.z), cell_size)
					local_aabb = local_aabb.grow(0.1 + (0.05 / 2.0))
					#print("Local AABB: ", local_aabb)
					
					var new_start : bool = false
					
					for position_string : Array[Vector3] in location_strings:
						for idx in range(1, position_string.size() - 1):
							var edge : Array[Vector4] = [Vector4(position_string[idx - 1].x, position_string[idx - 1].y, position_string[idx - 1].z, 0.0), Vector4(position_string[idx].x, position_string[idx].y, position_string[idx].z, 0.0)]
							
							var start : Vector3 = Vector3(edge[0].x, edge[0].y, edge[0].z)
							var end : Vector3 = Vector3(edge[1].x, edge[1].y, edge[1].z)
							
							if local_aabb.intersects_segment(start, end):
								
								if idx == position_string.size() - 1:
									edge[0].w = float(new_start) * 0.6
								
								if cell.size() == 0:
									cell.append_array(edge)
								else:
									cell.append(edge[1])
							
		#print(cells)
		
		var img_resolution : int = sqrt(pow(resolution, 3.0))
		var img : Image = Image.create_empty(img_resolution * 4.0, img_resolution * 4.0 + 1, false, Image.Format.FORMAT_RGBAF)
		img.fill(Color.WHITE)
		img.fill_rect(Rect2i(0, 0, img_resolution * 3.0, 1), Color.BLACK)
		img.set_pixel(0, 0, Color(mesh_aabb.size.x / 100000.0, mesh_aabb.size.y / 100000.0, mesh_aabb.size.z / 100000.0)) # This means the theoretical max size of a mesh could be 100 000 meters on all axes
		img.set_pixel(1, 0, Color((mesh_aabb.position.x + 50000) / 100000.0, (mesh_aabb.position.y  + 50000) / 100000.0, (mesh_aabb.position.z + 50000) / 100000.0))
		
		for x_step in resolution:
			for y_step in resolution:
				for z_step in resolution:
					var x_offset : int = x_step * 4
					var y_offset : int = y_step * 4 + 1
					var z_offset : Vector2i = Vector2i(fmod(z_step, sqrt(resolution)), floor(float(z_step) / sqrt(resolution))) * resolution * 4
					
					var position : Vector2i = Vector2i(x_offset, y_offset) + z_offset
					
					var cell : Array = cells[x_step][y_step][z_step]
					
					if !cell.is_empty():
						var idx : int = 0
						for pos : Vector4 in cell:
							var local_x_offset : int = idx % 4
							var local_y_offset : int = floori(float(idx) / 4.0)
							var local_offset : Vector2i = Vector2i(local_x_offset, local_y_offset)
							
							img.set_pixel(position.x + local_x_offset, position.y + local_y_offset, Color((pos.x + 50000) / 100000, (pos.y + 50000) / 100000, (pos.z + 50000) / 100000, pos.w))
							
							idx += 1
		
		img.save_png("res://output_img.png")
		images.append(img)
					
		
		#for i in mdt.get_vertex_count():
			#i = vertex_duplicates_map[i]
			#
			#if mdt.get_vertex_color(i) == Color.WHITE:
				#print("Found starting vertex: ", i)
				#starting_vertex_idx = i
				#current_vertex_idx = i
				#previous_vertex_idx = i
				#break
		#
		#var iter : int = 0
		#var finished : bool = false
		#while !finished:
			#iter += 1
			#if iter > 10:
				#print("ended")
				#break
			#
			#var next_vertex : int
			#var vertex_edges = mdt.get_vertex_edges(current_vertex_idx)
			#
			#print("\ncurrent vertex: ", current_vertex_idx)
			#
			#print("edges: ", vertex_edges)
			#
			#var eligible_neighbors : Array[int]
			#
			#for edge_idx in vertex_edges:
				#print("checking edge ", edge_idx)
				#
				#var v1 = vertex_duplicates_map[mdt.get_edge_vertex(edge_idx, 0)]
				#var v2 = vertex_duplicates_map[mdt.get_edge_vertex(edge_idx, 1)]
				#
				#if checked_edges.has([v1, v2]) or checked_edges.has([v2, v1]):
					#print("already passed this edge")
					#continue
				#
				#checked_edges.append([v1, v2])
				#
				#print("edge vertices: ", v1, ", ", v2)
				#print("vertex colors: ", mdt.get_vertex_color(v1), ", ", mdt.get_vertex_color(v2))
				#
				#if v1 == current_vertex_idx:
					#if v2 == previous_vertex_idx:
						#continue
					#
					#if mdt.get_vertex_color(v2) == Color.WHITE:
						#print("found next vertex: ", v2)
						#eligible_neighbors.append(v2)
						#continue
				#
				#
				#elif v2 == current_vertex_idx:
					#if v1 == previous_vertex_idx:
						#continue
					#
					#if mdt.get_vertex_color(v1) == Color.WHITE:
						#print("found next vertex: ", v1)
						#eligible_neighbors.append(v1)
						#continue
			#
			##if !next_vertex:
				##print("nothing found, continue")
				##continue
			#
			#print("eligible neighbors: ", eligible_neighbors)
			#
			#next_vertex = eligible_neighbors[0]
			#
			#previous_vertex_idx = current_vertex_idx
			#current_vertex_idx = vertex_duplicates_map[next_vertex]
			#
				#
			#
			#pass
		#while current_vertex_idx != INF:
			#break
			#
			#var vertex : Vector3 = mdt.get_vertex(current_vertex_idx)
			#
			#if mdt.get_vertex_color(current_vertex_idx) != Color.WHITE:
				#continue
			#
			#edge_strings[current_edge_string].append(current_vertex_idx)
			#
			#var edges = mdt.get_vertex_edges(current_vertex_idx)
			#var neighboring_vertices : Array[int]
			#
			#for edge_idx : int in edges:
				#var v1 = mdt.get_edge_vertex(edge_idx, 0)
				#var v2 = mdt.get_edge_vertex(edge_idx, 1)
				#
				#print(current_vertex_idx, previous_vertex_idx)
				#print("edge ", v1, v2)
				#
				#if v1 != current_vertex_idx and v1 != previous_vertex_idx and mdt.get_vertex_color(v1) == Color.WHITE:
					#neighboring_vertices.append(v1)
				#elif v2 != current_vertex_idx and v2 != previous_vertex_idx and mdt.get_vertex_color(v2) == Color.WHITE:
					#neighboring_vertices.append(v2)
			#
			#break
			#
			#if neighboring_vertices.is_empty():
				#break
			#
			#previous_vertex_idx = current_vertex_idx
			#current_vertex_idx = neighboring_vertices.back()
			#
			#if current_vertex_idx == 0:
				#print("found end")
				#break
		
		#for location : Vector3 in location_string:
			#print("adding location ", location)
			#vertex_list.append(Vector4(location.x, location.y, location.z, 1.0))
		
		#endregion comment
		
		#var vertex_list : Array[Vector4] = []
		#
		#var test = PackedVector4Array(vertex_list)
		#test.resize(100*100)
		#
		#var _new_image := Image.create_from_data(100, 100, false, Image.FORMAT_RGBAF, test.to_byte_array())
		#images.append(_new_image)
			
	var texture : ImageTexture = ImageTexture.create_from_image(images[0])
	#ResourceSaver.save(texture, "res://test_array.tres")
	#ResourceSaver.save(material, "res://test.tres", ResourceSaver.FLAG_OMIT_EDITOR_PROPERTIES)
	
	material.set_shader_parameter_persistent("line_maps", texture)
	material.set_shader_parameter_persistent("line_map_count", images.size())
	
	#EditorInterface.save_scene()
	
	#ResourceLoader.load(material.set_path_cache(), )
	
	#ResourceSaver.save(material)

func array_unique(array: Array[Array]) -> Array[Array]:
	var unique : Array[Array] = []

	for item in array:
		if not unique.has(item):
			unique.append(item)

	return unique
	
func _exit_tree() -> void:
	pass

func register_material(material : ShaderMaterial) -> void:
	materials[material] = {}

func register_mesh_instance(instance : CPMMeshInstance3D, used_materials : Array[ShaderMaterial]) -> void:
	for material : ShaderMaterial in used_materials:
		if !materials.has(material):
			register_material(material)
		
		if materials[material].has(instance):
			printerr("This CPMMeshInstance3D was already registered under this material. Try updating instead. Ignoring.")
			#return
		
		materials[material][instance] = {"global_position": instance.global_position} # currently nothing is done with this dictionary
		if !instance.global_position_changed.is_connected(_update_mesh_instance_position):
			instance.global_position_changed.connect(_update_mesh_instance_position.bind(instance, material))
		
		_generate_material_linemaps(material)

func _update_material_positions_list(material : ShaderMaterial) -> void:
	#print("update positions list")
	if !materials.has(material):
		printerr("bla bla")
		return
	
	var _positions : Array[Vector3] = []
	for instance : CPMMeshInstance3D in materials[material].keys():
		_positions.append(instance.global_position)
	
	material.set_shader_parameter("instance_positions", _positions)

func _update_mesh_instance_position(new_global_position : Vector3, instance : MeshInstance3D, material : ShaderMaterial) -> void:
	if !materials.has(material):
		printerr("Material hasn't been registered. Aborting.")
		return
		
	if !materials[material].has(instance):
		printerr("CPMMeshInstance3D hasn't been registered. Aborting")
		return
	
	#materials[material][instance].global_position = new_global_position
	
	_update_material_positions_list(material)
	

#func initialize_arrays() -> void:
	#positions.resize(16384 * 4)
	#positions.fill(0)
	#
	#dimensions.resize(16384 * 4)
	#dimensions.fill(0)
#
#
#func register_shape(shape : CPMEffectShape) -> void:
	##print(shape)
	#if !effect_shapes.has(shape):
		#effect_shapes.append(shape)
		#RenderingServer.global_shader_parameter_set("cpm_effect_shapes_num", effect_shapes.size())
		##print(RenderingServer.global_shader_parameter_get("cpm_effect_shapes_num"))
	#
	##print(effect_shapes)
#
#func deregister_shape(shape : CPMEffectShape) -> void:
	#if effect_shapes.has(shape):
		#effect_shapes.erase(shape)
		#initialize_arrays()
		#update_all()
#
#func notify_moved(shape : CollisionShape3D) -> void:
	##print("shape ", shape, " moved, update it")
	#update_specific_shape(shape)
#
#func notify_dimensions_changed(shape : CollisionShape3D) -> void:
	#
	#update_specific_shape(shape)
#
#func update_textures() -> void:
	#var _idx : int = 0
	#for shape : CollisionShape3D in effect_shapes:
		#update_textures_for_shape(shape, _idx)
		#_idx += 1
#
#func update_all() -> void:
	#for shape in effect_shapes:
		#update_specific_shape(shape)
#
#func update_specific_shape(shape : CollisionShape3D) -> void:
	#assert(effect_shapes.has(shape), "CPMEffectShape was not registered and can not be updated.")
	#if !effect_shapes.has(shape):
		#return
	#
	#var _shape_idx : int = effect_shapes.find(shape)
	##print("shape idx: ", _shape_idx)
#
	#update_textures_for_shape(shape, _shape_idx)
#
#
#func update_textures_for_shape(shape : CollisionShape3D, pixel_idx : int) -> void:
	##print("updating shape ", shape, " starting from pixel ", pixel_idx * 3)
	#positions[pixel_idx * 4] = (shape.global_position.x + 75000.0) / 150000.0
	#positions[pixel_idx * 4 + 1] = (shape.global_position.y + 75000.0) / 150000.0
	#positions[pixel_idx * 4 + 2] = (shape.global_position.z + 75000.0) / 150000.0
	#
	#dimensions[pixel_idx * 4] = shape.shape.radius / 150000.0
	#
	#rendering_device.texture_update(texture_rid, 0, positions.to_byte_array())
	##rendering_device.texture_update(texture_rid, 1, types.to_byte_array())
	#rendering_device.texture_update(texture_rid, 2, dimensions.to_byte_array())
#
##func erase_shape_data
