@tool
extends CompositeMaterialBuilderGraphNode

var represented_configuration : CPMB_EffectShapeMaskConfiguration

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	represented_configuration = CPMB_EffectShapeMaskConfiguration.new()
	
	$layer.value_changed.connect(func(x): represented_configuration.layer = x)
	$falloff_distance.value_changed.connect(func(x): represented_configuration.falloff_distance = x)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_represented_object(port_idx : int) -> Object:
	return represented_configuration

func set_represented_object(object : Object) -> void:
	represented_configuration = object
