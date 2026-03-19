@tool
extends CompositeMaterialBuilderGraphNode

func _ready() -> void:
	print("whoopsie")
	var _tex = NoiseTexture2D.new()
	_tex.noise = FastNoiseLite.new()
	_tex.noise.seed = randi_range(0, 1000000)
	
	var _config = CPMB_TextureConfiguration.new()
	_config.texture = _tex
	$TextureNode.set_represented_object(_config)
	
	print(position_offset)
	$TextureNode.position_offset = position_offset
	$TextureNode.reparent(get_parent())
	queue_free()
