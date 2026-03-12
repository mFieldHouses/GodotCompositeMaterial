@tool
extends CompositeMaterialBuilderGraphNode
class_name VectorOperationNode

enum OperationType {
	COMPOSE, DECOMPOSE,
	ADD, SUBTRACT, MULTIPLY, DIVIDE,
	POWER, ROOT, LOGARITHM, NATURAL_LOGARITHM
}

var represented_config : CPMB_VectorOperationConfiguration

var ports : Array[Array] = [] #Sub-arrays structure: [(int from -1 to 1), (non-signed int)]

# Called when the node enters the scene tree for the first time.
func _node_ready() -> void:
	represented_config = CPMB_VectorOperationConfiguration.new()
	
	$configuration/type.item_selected.connect(select_vector_type)
	$configuration/operation.item_selected.connect(select_operation)

func select_vector_type(idx : int) -> void:
	represented_config.vector_type = $configuration/type.get_item_id(idx)
	$vector_out.text = "Vector" + str(represented_config.vector_type + 2) + " out"
	
	match represented_config.vector_type:
		0:
			represented_config.source_vector = CPMB_Vector2Value.new()
		1:
			represented_config.source_vector = CPMB_Vector3Value.new()
		2:
			represented_config.source_vector = CPMB_Vector4Value.new()
	
	update_node()

func select_operation(idx : int) -> void:
	represented_config.operation = $configuration/operation.get_item_id(idx)
	update_node()

func update_vector_labels() -> void:
	$vector_out.text = "Vector" + str(represented_config.vector_type + 2) + " out"
	$vec_in.text = "Vector" + str(represented_config.vector_type + 2)

func update_ports() -> void:
	var _idx : int = 0
	for port_config in ports:
		set_slot_enabled_left(_idx + 1, false) #+1 everywhere to skip over $configuration
		set_slot_enabled_right(_idx + 1, false)
		
		if port_config.size() == 0:
			continue
		
		match port_config[0]:
			-1:
				set_slot_enabled_left(_idx + 1, true)
				set_slot_type_left(_idx + 1, port_config[1])
			1:
				set_slot_enabled_right(_idx + 1, true)
				set_slot_type_right(_idx + 1, port_config[1])
		
		_idx += 1

func update_node() -> void:
	
	update_vector_labels()
	
	$configuration.visible = true
	$vector_out.visible = true
	
	$configuration/operation.selected = represented_config.operation + 1
	$configuration/type.selected = represented_config.vector_type
	
	ports.resize(5)
	ports.fill([])
	
	for child in get_children():
		if child.name == "configuration" or child.name == "vector_out":
			continue
		
		child.visible = false
	
	match represented_config.operation:
		0: #compose
			ports[0] = [1, 3]
			$x_in.visible = true
			ports[1] = [-1, 5]
			$y_in.visible = true
			ports[2] = [-1, 5]
			$z_in.visible = true
			ports[3] = [-1, 5]
			$w_in.visible = false
			
			match represented_config.vector_type:
				0:
					$z_in.visible = false
					ports[0][1] = 4
					ports[3] = [0, 5]
				2:
					$w_in.visible = true
					ports[0][1] = 2
					ports[4] = [-1, 5]
		1: #decompose
			ports[0] = [-1, 3]
			$vec_in.visible = true
			$vector_out.visible = false
			
			$x_out.visible = true
			ports[1] = [1, 5]
			$y_out.visible = true
			ports[2] = [1, 5]
			$z_out.visible = true
			ports[3] = [1, 5]
			$w_out.visible = false
			
			match represented_config.vector_type:
				0:
					$z_out.visible = false
					ports[0][1] = 4
					ports[3] = [0, 5]
				2:
					$w_out.visible = true
					ports[0][1] = 2
					ports[4] = [1, 5]
		2: #add
			pass
	
	size.y = 0
	
	update_ports()

func get_represented_object(port_idx : int) -> Object:
	var _result : CPMB_Base
	
	match represented_config.operation:
		0:
			match represented_config.vector_type:
				0:
					_result = CPMB_ComposeVec2.new()
				1:
					_result = CPMB_ComposeVec3.new()
					_result.z = represented_config.z_in
				2:
					_result = CPMB_ComposeVec4.new()
					_result.z = represented_config.z_in
					_result.w = represented_config.w_in
			
			_result.x = represented_config.x_in
			_result.y = represented_config.y_in
			
		1:
			print("returning decompose config")
			match represented_config.vector_type:
				0:
					_result = CPMB_DecomposeVec2.new()
				1:
					_result = CPMB_DecomposeVec3.new()
				2:
					_result = CPMB_DecomposeVec4.new()
			
			print("channel: ", port_idx)
			_result.output_channel = port_idx
			print("source: ", represented_config.source_vector)
			_result.source_vector = represented_config.source_vector
	
	_result.source_identifier = represented_config.identifier
	return _result

func set_represented_object(object : Object) -> void:
	
	if object is CPMB_VectorOperationConfiguration:
		represented_config = object
	elif object is CPMB_DecomposeVec4:
		represented_config.vector_type = CPMB_VectorOperationConfiguration.VectorType.VECTOR4
		represented_config.operation = CPMB_VectorOperationConfiguration.OperationType.DECOMPOSE
	
	update_node()

func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	match represented_config.operation:
		0:
			match input_port_id:
				0:
					represented_config.x_in = object
				1:
					represented_config.y_in = object
				2:
					represented_config.z_in = object
				3:
					represented_config.w_in = object
		1:
			#print("connected new input: ", object)
			represented_config.source_vector = object
