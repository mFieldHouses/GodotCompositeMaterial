@tool
extends CPMB_Vector4Value
class_name CPMB_TextureConfiguration

@export var uv : CPMB_Vector2Value = CPMB_UVMapConfiguration.new()
@export var texture : Texture2D:
	set(x):
		texture = x
		value_changed.emit(x, "textures")

func get_expression() -> String:
	return "texture(textures[%s], %s)" % [index, uv.get_expression()]
