@tool
extends CompositeMaterialBuilderGraphNode
class_name VariableNode

var type : Variant.Type

var represented_value : CPMB_Base

const OUTPUT_PORT_INDEX : int = 3

func _node_ready() -> void:
	$type.item_selected.connect(_type_chosen)
	
	$is_variable.toggled.connect(set_variable)


func set_variable(state : bool) -> void:
	represented_value.is_variable = state
	represented_value.variable_name = title

func _type_chosen(id : int) -> void:
	
	request_disconnect_self.emit()
	
	$is_variable.disabled = false
	
	$bool_field.visible = false
	$float_field.visible = false
	$int_field.visible = false
	$color_field.visible = false
	$vector2_field.visible = false
	$vector3_field.visible = false
	
	set_slot_enabled_right(OUTPUT_PORT_INDEX, true)
	
	match id:
		1:
			type = TYPE_INT
			$int_field.visible = true
			set_slot_type_right(OUTPUT_PORT_INDEX, 5)
			represented_value = CPMB_IntValue.new(1)
		2:
			type = TYPE_FLOAT
			$float_field.visible = true
			set_slot_type_right(OUTPUT_PORT_INDEX, 5)
			represented_value = CPMB_FloatValue.new(1.0)
		3:
			type = TYPE_BOOL
			$bool_field.visible = true
			set_slot_type_right(OUTPUT_PORT_INDEX, 8)
			represented_value = CPMB_BoolValue.new()
		4:
			type = TYPE_COLOR
			$color_field.visible = true
			set_slot_type_right(OUTPUT_PORT_INDEX, 3)
			represented_value = CPMB_Vector3Value.new(Vector3(1.0, 0.0, 0.0))
			represented_value.as_color = true
		5:
			type = TYPE_VECTOR2
			$vector2_field.visible = true
			set_slot_type_right(OUTPUT_PORT_INDEX, 4)
			represented_value = CPMB_ComposeVec2.new()
		6:
			type = TYPE_VECTOR3
			$vector3_field.visible = true
			set_slot_type_right(OUTPUT_PORT_INDEX, 3)
			represented_value = CPMB_ComposeVec3.new()
	
	#represented_value.internal_to_node = true
	represented_value.variable_name = title
	size.y = 0
	
	$int_field/value.value_changed.connect(func(x): represented_value.value = x)
	$float_field/value.value_changed.connect(func(x): represented_value.value = x)
	
	$bool_field/value.toggled.connect(func(x): represented_value.value = x)
	
	$color_field/color.color_changed.connect(func(x): represented_value.value = Vector3(x.r, x.g, x.b))
	
	$vector2_field/x/value.value_changed.connect(func(x): represented_value.x.value = x)
	$vector2_field/y/value.value_changed.connect(func(x): represented_value.y.value = x)
	
	$vector3_field/x/value.value_changed.connect(func(x): represented_value.x.value = x)
	$vector3_field/y/value.value_changed.connect(func(x): represented_value.y.value = x)
	$vector3_field/y/value.value_changed.connect(func(x): represented_value.z.value = x)
	
func get_represented_object(port_idx : int) -> Object:
	return represented_value

func set_represented_object(object : Object) -> void:
	
	print("set represented object on valuenode to ", object)
	
	if object is CPMB_IntValue:
		_type_chosen(1)
		$type.selected = 1
		
		$int_field/value.value = object.value
		
	elif object is CPMB_FloatValue:
		_type_chosen(2)
		$type.selected = 2
		
		$float_field/value.value = object.value
		
	elif object is CPMB_BoolValue:
		_type_chosen(3)
		$type.selected = 3
		
		$bool_field/value.value = object.value
		
	elif object is CPMB_ComposeVec3:
		_type_chosen(5)
		$type.selected = 5
			
		$vector3_field/x/value.value = object.x.value
		$vector3_field/y/value.value = object.y.value
		$vector3_field/z/value.value = object.z.value
	
	elif object is CPMB_Vector3Value:
		_type_chosen(4)
		$type.selected = 4
			
		$color_field/color.color = Color(object.value.x, object.value.y, object.value.z)
	
	elif object is CPMB_ComposeVec2:
		_type_chosen(6)
		$type.selected = 6
		
		$vector3_field/x/value.value = object.x.value
		$vector3_field/y/value.value = object.y.value
		$vector3_field/z/value.value = object.z.value
	
	$is_variable.button_pressed = object.is_variable
	if object.is_variable:
		title = object.variable_name
	
	represented_value = object
	
	$is_variable.button_pressed = represented_value.is_variable
