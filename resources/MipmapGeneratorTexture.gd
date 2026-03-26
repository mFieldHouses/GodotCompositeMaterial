@tool
extends ImageTexture
class_name MipmapGeneratorTexture

var _image : Image
var _image_texture : ImageTexture

@export var input_texture : Texture2D:
	set(x):
		input_texture = x
		_update()

@export_tool_button("Update") var update_action = _update

func _update() -> void:
	_image = input_texture.get_image()
	_image.generate_mipmaps()
	set_image(_image)
	emit_changed()

func _get_rid() -> RID:
	return _image_texture.get_rid()

func _get_height() -> int:
	return input_texture.get_height()

func _get_width() -> int:
	return input_texture.get_width()
