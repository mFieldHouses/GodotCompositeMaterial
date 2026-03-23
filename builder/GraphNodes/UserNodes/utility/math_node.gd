@tool
extends CompositeMaterialBuilderGraphNode

enum OperationType {
	ADD, SUBTRACT, MULTIPLY, DIVIDE,
	POWER, ROOT, LOGARITHM, NATURAL_LOGARITHM
}

var represented_config : CPMB_Math

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	represented_config = CPMB_Math.new()
	$operation.item_selected.connect(change_operation)
	
	$value_1/value.value_changed.connect(func(x): if represented_config.value_A.internal_to_node: represented_config.value_A.value = x)
	$value_2/value.value_changed.connect(func(x): if represented_config.value_B.internal_to_node: represented_config.value_B.value = x)


func change_operation(idx : int) -> void:
	represented_config.operation = $operation.get_item_id(idx)

func get_represented_object(port_idx : int) -> Object:
	#print("get represented object of math node")
	return represented_config

func set_represented_object(object : Object) -> void:
	#print("set represented object on mathnode: ", object)
	#print("object has operation ", object.operation)
	represented_config = object
	#print("I now have operation ", represented_config.operation)
	
	$operation.selected = $operation.get_item_index(represented_config.operation)
	#$value_1/value.value = represented_config.value_A.value
	#$value_2/value.value = represented_config.value_B.value


func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	match input_port_id:
		0:
			represented_config.value_A = object
		1:
			represented_config.value_B = object
