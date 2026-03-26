@tool
extends CompositeMaterialBuilderGraphNode

var represented_configuration : CPMB_EffectShapeMaskConfiguration

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	represented_configuration = CPMB_EffectShapeMaskConfiguration.new()
	
	$layer.value_changed.connect(func(x): represented_configuration.layer = x)
	$falloff_distance.value_changed.connect(func(x): represented_configuration.falloff_distance = x)

func get_represented_object(port_idx : int) -> Object:
	return represented_configuration

func set_represented_object(object : Object) -> void:
	represented_configuration = object
