@tool
extends CPMB_Vector4Value
class_name CPMB_TextureConfiguration

@export var uv : CPMB_Vector2Value
@export var texture : Texture2D:
	set(x):
		texture = x
		value_changed.emit(x, "textures")

func _init() -> void:
	initialise_value()
	
	value = Vector4.INF

func initialise_value(index : int = -1) -> void:
	uv = CPMB_UVMapConfiguration.new()

func get_expression() -> String:
	return "texture(textures[%s], %s)" % [index, uv.get_expression()]
