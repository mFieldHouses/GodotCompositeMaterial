@tool
extends Node

##Autoload that manages autoload shapes and exposes them to shaders using shader globals and textures.

var texture_dimensions : Vector2i = Vector2i(4, 4)

var effect_shapes : Array[CPMEffectShape]

var shapes_positions1_image : Image ##Texture in which the positions of all EffectShapes are stored
var shapes_positions2_image : Image
var shapes_configurations_texture : Image ##Texture in which data describing EffectShape layers and types are stored
var shapes_sizes_texture : Image ##Texture in which data describing the size of EffectShapes is stored

var texture_array : Texture2DArray

func _ready() -> void:
	shapes_positions1_image = Image.create_empty(texture_dimensions.x, texture_dimensions.y, false, Image.FORMAT_RGBA16)
	shapes_positions2_image = Image.create_empty(texture_dimensions.x, texture_dimensions.y, false, Image.FORMAT_RGBA16)
	shapes_configurations_texture = Image.create_empty(texture_dimensions.x, texture_dimensions.y, false, Image.FORMAT_RGBA16)
	shapes_sizes_texture = Image.create_empty(texture_dimensions.x, texture_dimensions.y, false, Image.FORMAT_RGBA16)

	texture_array = Texture2DArray.new()
	texture_array.create_from_images([shapes_positions1_image, shapes_positions2_image, shapes_configurations_texture, shapes_sizes_texture])


func _enter_tree() -> void:
	RenderingServer.global_shader_parameter_add("cpm_effect_shape_textures", RenderingServer.GLOBAL_VAR_TYPE_SAMPLER2DARRAY, texture_array)
	
	
func _exit_tree() -> void:
	RenderingServer.global_shader_parameter_remove("cpm_effect_shape_textures")


func register_shape(shape : CPMEffectShape) -> void:
	#print(shape)
	if !effect_shapes.has(shape):
		effect_shapes.append(shape)
	
	#print(effect_shapes)

func deregister_shape(shape : CPMEffectShape) -> void:
	if effect_shapes.has(shape):
		effect_shapes.erase(shape)

func notify_moved(shape : CollisionShape3D) -> void:
	#print("shape ", shape, " moved, update it")
	update_specific_shape(shape)

func update_textures() -> void:
	var _idx : int = 0
	for shape : CollisionShape3D in effect_shapes:
		var _pixel_pos : Vector2i = get_pixel_pos_for_index(_idx)
		
		update_textures_for_shape(shape, _pixel_pos)
		
		_idx += 1

func update_specific_shape(shape : CollisionShape3D) -> void:
	assert(effect_shapes.has(shape), "CPMEffectShape was not registered and can not be updated.")
	if !effect_shapes.has(shape):
		return
	
	var _shape_idx : int = effect_shapes.find(shape)
	var _pixel_pos : Vector2i = get_pixel_pos_for_index(_shape_idx)
	
	update_textures_for_shape(shape, _pixel_pos)


func get_pixel_pos_for_index(index : int) -> Vector2i:
	return Vector2i(index % texture_dimensions.x, ceili(index + 1 / texture_dimensions.x))

func update_textures_for_shape(shape : CollisionShape3D, pixel_position : Vector2i) -> void:
	
	print(Color(
			clamp(shape.global_position.x, 0.0, pow(2, 16)) / pow(2, 16),
			clamp(shape.global_position.y, 0.0, pow(2, 16)) / pow(2, 16),
			clamp(shape.global_position.z, 0.0, pow(2, 16)) / pow(2, 16)
			)
		)
	
	shapes_positions1_image.set_pixel(pixel_position.x, pixel_position.y, 
		Color(
			clamp(shape.global_position.x + pow(2, 16), 0.0, pow(2, 16)) / pow(2, 16),
			clamp(shape.global_position.y + pow(2, 16), 0.0, pow(2, 16)) / pow(2, 16),
			clamp(shape.global_position.z + pow(2, 16), 0.0, pow(2, 16)) / pow(2, 16)
			)
		)
	texture_array.update_layer(shapes_positions1_image, 0)
		
	shapes_positions2_image.set_pixel(pixel_position.x, pixel_position.y, 
		Color(
			clamp(shape.global_position.x, 0.0, pow(2, 16)) / pow(2, 16),
			clamp(shape.global_position.y, 0.0, pow(2, 16)) / pow(2, 16),
			clamp(shape.global_position.z, 0.0, pow(2, 16)) / pow(2, 16)
			)
		)
	texture_array.update_layer(shapes_positions2_image, 1)
	
	print("result: ", shapes_positions2_image.get_pixel(0,0))
