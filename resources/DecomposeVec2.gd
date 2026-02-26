extends CPMB_FloatValue
class_name CPMB_DecomposeVec2

@export var source_value : Variant
@export_enum("X", "Y", "Length") var output_channel : int = 0

func get_value() -> float:
	if source_value is not Vector2:
		return 0.0 
	
	else:
		match output_channel:
			0:
				return source_value.x
			1:
				return source_value.y
			4:
				return source_value.length()
	
	return 0.0
