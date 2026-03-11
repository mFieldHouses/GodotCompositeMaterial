@tool
extends ImageTexture
class_name DepthToNormalTexture

@export var source_depth_map : Texture2D:
	set(x):
		source_depth_map = x
		update_image()

var _image : Image

var _imagem = ImageM.new()

func _init() -> void:
	update_image()

func update_image() -> void:
	print(source_depth_map)
	if source_depth_map == null:
		printerr("No source depth map set. Cannot proceed.")
		return
	
	#var _depth_image = source_depth_map.get_image()
	#_image = Image.create_empty(source_depth_map.get_width(), source_depth_map.get_height(), true, Image.FORMAT_RGB16)
	#_image.set_pixel(10,10,Color.WHITE)	
	
	#for x in get_width():
		#for y in get_height():
			#pass
			#var _left = _depth_image.get_pixel(x - 1, y)
			#var _right = _depth_image.get_pixel(x + 1, y)
			#var _top = _depth_image.get_pixel(x, y - 1)
			#var _bottom = _depth_image.get_pixel(x, y + 1)
			
			#var _color = Color(0.5, 0.5, 1.0)
	
	#print(_imagem.normal_map_from_depth_map(source_depth_map.get_image()))
	set_image(_imagem.normal_map_from_depth_map(source_depth_map).get_image())
	
	emit_changed()
