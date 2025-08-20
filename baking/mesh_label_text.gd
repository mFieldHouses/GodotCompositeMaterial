@tool
extends RichTextLabel

func update_name(primary_name : String, output_name : String, supported : bool = true):
	var result = primary_name
	
	if !supported:
		result = "[color=#FA8080]" + result
		
	if output_name != "":
		result = result + " [color=#808080] -> " + output_name
	
	text = result
