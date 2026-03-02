@tool
extends Node

##Autoload that manages autoload shapes and exposes them to shaders using shader globals and textures.

var effect_shapes : Array[CPMEffectShape]

var shapes_positions_texture : Texture2D ##Texture in which the positions of all EffectShapes are stored
var shapes_configurations_texture : Texture2D ##Texture in which data describing EffectShape layers and types are stored
var shapes_sizes_texture : Texture2D ##Texture in which data describing the size of EffectShapes is stored

func register_shape(shape : CPMEffectShape) -> void:
	if !effect_shapes.has(shape):
		effect_shapes.append(shape)

func deregister_shape(shape : CPMEffectShape) -> void:
	if effect_shapes.has(shape):
		effect_shapes.erase(shape)
