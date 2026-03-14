extends Resource
class_name CPMB_Base

signal request_material_rebuild

@export var is_descendant_resource : bool = false ##Set this to true on any resource that gets returned as the represented object on a node instead of the nodes actual represented object
@export var internal_to_node : bool = false ##Set this to true on any resource that gets created as a placeholder for other input resources.
var index : int = 0: ##Index of this resource in the shader uniform arrays. Used to build the returned expression.
	set(x):
		index = x
		#print("index got set to ", x, " for ", self)
		
func get_expression() -> String: ##Must be overridden. Returns an expression in GDShader syntax.
	return ""

func get_output_port_for_state() -> int: ##Can be overridden
	return 0

func initialise_value(index : int = -1) -> void: ##Override this function
	pass

func get_mapping_key() -> String: ##Returns the key under which this resource will be appended in the resource map. If this is left unoverridden, nothing will be appended to the resource map.
	return ""

func get_node_name() -> String: ##Returns the path to the node that represents this resource relative to res://addons/CompositeMaterial/builder/GraphNodes/UserNodes/
	return ""

func get_input_port_resources() -> Dictionary[CPMB_Base, int]: 
	return {}

func instantiate_representing_node(base_page : CompositeMaterialBuilderPage) -> void:
	pass

func get_child_resources() -> Array[CPMB_Base]: ##Returns an array of resources that this resource contains.
	return []

func on_mapped(resource_map : Dictionary[String, Array]) -> void: ##Optional. Gets called when the resource gets mapped.
	pass
