@tool
extends CompositeMaterialBuilderGraphNode

var monitored_value : CPMB_Base


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$value_text.text = "Value: "
	$x_text.text = "X: "
	$y_text.text = "Y: "
	$z_text.text = "Z: "
	$w_text.text = "W: "
	
	if monitored_value is CPMB_FloatValue or monitored_value is CPMB_IntValue or monitored_value is CPMB_BoolValue:
		$value_text.text += str(monitored_value.value)
	elif monitored_value is CPMB_Vector2Value:
		$x_text.text += str(monitored_value.value.x)
		$y_text.text += str(monitored_value.value.y)
	elif monitored_value is CPMB_Vector3Value:
		$x_text.text += str(monitored_value.value.x)
		$y_text.text += str(monitored_value.value.y)
		$z_text.text += str(monitored_value.value.z)
	elif monitored_value is CPMB_Vector4Value:
		$x_text.text += str(monitored_value.value.x)
		$y_text.text += str(monitored_value.value.y)
		$z_text.text += str(monitored_value.value.z)
		$w_text.text += str(monitored_value.value.w)

func connect_and_pass_object(input_port_id : int, object : Object) -> void:
	print(object)
	monitored_value = object
	
	for child in get_children():
		if child.name != "Label":
			child.visible = false
	
	if monitored_value is CPMB_FloatValue or monitored_value is CPMB_IntValue or monitored_value is CPMB_BoolValue:
		$value_text.visible = true
	elif monitored_value is CPMB_Vector2Value:
		$x_text.visible = true
		$y_text.visible = true
	elif monitored_value is CPMB_Vector3Value:
		$x_text.visible = true
		$y_text.visible = true
		$z_text.visible = true
	elif monitored_value is CPMB_Vector4Value:
		$x_text.visible = true
		$y_text.visible = true
		$z_text.visible = true
		$w_text.visible = true
	else:
		$not_monitorable.visible = true
	
	size.y = 0
