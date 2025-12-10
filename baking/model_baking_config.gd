extends Resource
class_name ModelBakingConfig

##Config for a complete model to be baked, cached and retrievable for quick iteration

@export var mesh_configs : Dictionary #String, int

@export var generate_model : bool = false
@export var model_generation_mode : int = 0
@export var model_output_path : String = ""
