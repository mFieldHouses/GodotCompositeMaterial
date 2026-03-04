@tool
extends Node

##Autoload that manages effect shapes and exposes them to shaders using global uniforms and textures.

# Code for interfacing with RenderingDevice was taken from
# https://github.com/godotengine/godot-proposals/discussions/9553#discussioncomment-15599036

var effect_shapes : Array[CPMEffectShape]

var rendering_device : RenderingDevice
var texture_rid : RID

var positions : PackedFloat32Array = [] #layer 0 of the texture
var types : PackedInt32Array = [] #layer 1 of the texture
var dimensions : PackedFloat32Array = [] #layer 2 of the texture

func _ready() -> void:
	
	RenderingServer.global_shader_parameter_add("cpm_effect_shape_textures", RenderingServer.GLOBAL_VAR_TYPE_SAMPLER2DARRAY, null)
	RenderingServer.global_shader_parameter_add("cpm_effect_shapes_num", RenderingServer.GLOBAL_VAR_TYPE_INT, 0)
	
	RenderingServer.call_on_render_thread(_initialize_rendering)

func _initialize_rendering() -> void:
	rendering_device = RenderingServer.get_rendering_device()
	
	var tf := RDTextureFormat.new()
	tf.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	tf.texture_type = RenderingDevice.TEXTURE_TYPE_2D_ARRAY
	tf.width = 16384
	tf.height = 1
	tf.depth = 3
	tf.array_layers = 3
	tf.mipmaps = 1
	tf.usage_bits = (
		RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT |
		RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT |
		RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
		)
	texture_rid = rendering_device.texture_create(tf, RDTextureView.new(), [])
	var texture := Texture2DArrayRD.new()
	texture.texture_rd_rid = texture_rid
	RenderingServer.global_shader_parameter_set("cpm_effect_shape_textures", texture)
	
	initialize_arrays()
	
	
func _exit_tree() -> void:
	RenderingServer.global_shader_parameter_remove("cpm_effect_shape_textures")


func initialize_arrays() -> void:
	positions.resize(16384 * 4)
	positions.fill(0)
	
	dimensions.resize(16384 * 4)
	dimensions.fill(0)


func register_shape(shape : CPMEffectShape) -> void:
	#print(shape)
	if !effect_shapes.has(shape):
		effect_shapes.append(shape)
		RenderingServer.global_shader_parameter_set("cpm_effect_shapes_num", effect_shapes.size())
		#print(RenderingServer.global_shader_parameter_get("cpm_effect_shapes_num"))
	
	#print(effect_shapes)

func deregister_shape(shape : CPMEffectShape) -> void:
	if effect_shapes.has(shape):
		effect_shapes.erase(shape)
		initialize_arrays()
		update_all()

func notify_moved(shape : CollisionShape3D) -> void:
	#print("shape ", shape, " moved, update it")
	update_specific_shape(shape)

func notify_dimensions_changed(shape : CollisionShape3D) -> void:
	
	update_specific_shape(shape)

func update_textures() -> void:
	var _idx : int = 0
	for shape : CollisionShape3D in effect_shapes:
		update_textures_for_shape(shape, _idx)
		_idx += 1

func update_all() -> void:
	for shape in effect_shapes:
		update_specific_shape(shape)

func update_specific_shape(shape : CollisionShape3D) -> void:
	assert(effect_shapes.has(shape), "CPMEffectShape was not registered and can not be updated.")
	if !effect_shapes.has(shape):
		return
	
	var _shape_idx : int = effect_shapes.find(shape)
	#print("shape idx: ", _shape_idx)

	update_textures_for_shape(shape, _shape_idx)


func update_textures_for_shape(shape : CollisionShape3D, pixel_idx : int) -> void:
	#print("updating shape ", shape, " starting from pixel ", pixel_idx * 3)
	positions[pixel_idx * 4] = (shape.global_position.x + 75000.0) / 150000.0
	positions[pixel_idx * 4 + 1] = (shape.global_position.y + 75000.0) / 150000.0
	positions[pixel_idx * 4 + 2] = (shape.global_position.z + 75000.0) / 150000.0
	
	dimensions[pixel_idx * 4] = shape.shape.radius / 150000.0
	
	rendering_device.texture_update(texture_rid, 0, positions.to_byte_array())
	#rendering_device.texture_update(texture_rid, 1, types.to_byte_array())
	rendering_device.texture_update(texture_rid, 2, dimensions.to_byte_array())

#func erase_shape_data
