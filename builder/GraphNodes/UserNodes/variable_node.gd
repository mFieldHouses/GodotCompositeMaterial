@tool
extends CompositeMaterialBuilderGraphNode

var type : Variant.Type

func _node_ready() -> void:
	$type.item_selected.connect(_type_chosen)
	
func get_value() -> Variant:
	match type:
		TYPE_INT:
			return $int_field/value.value
		TYPE_FLOAT:
			return $float_field/value.value
		TYPE_BOOL:
			return $bool_field/value.value
		TYPE_COLOR:
			return $color_field/color.color
	
	return null

func _type_chosen(id : int) -> void:
	$bool_field.visible = false
	$float_field.visible = false
	$int_field.visible = false
	$color_field.visible = false
	
	match id:
		1:
			type = TYPE_INT
			$int_field.visible = true
			set_slot_type_right(3, 5)
		2:
			type = TYPE_FLOAT
			$float_field.visible = true
			set_slot_type_right(3, 5)
		3:
			type = TYPE_BOOL
			$bool_field.visible = true
			set_slot_type_right(3, 8)
		4:
			type = TYPE_COLOR
			$color_field.visible = true
			set_slot_type_right(3, 2)
