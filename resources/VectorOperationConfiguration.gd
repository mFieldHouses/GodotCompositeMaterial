@tool
extends CPMB_NumericValue
class_name CPMB_VectorOperationConfiguration

@export var source_vector : CPMB_NumericValue

@export var x_in : CPMB_NumericValue
@export var y_in : CPMB_NumericValue
@export var z_in : CPMB_NumericValue
@export var w_in : CPMB_NumericValue

enum VectorType {VECTOR2, VECTOR3, VECTOR4}
@export var vector_type : VectorType = VectorType.VECTOR2

enum OperationType {
	COMPOSE, DECOMPOSE,
	ADD, SUBTRACT, MULTIPLY, DIVIDE,
	POWER, ROOT, LOGARITHM, NATURAL_LOGARITHM
}
@export var operation : OperationType = OperationType.ADD

func _init() -> void:
	x_in = CPMB_FloatValue.new()
	y_in = CPMB_FloatValue.new(0.0)
	z_in = CPMB_FloatValue.new()
	w_in = CPMB_FloatValue.new(1.0)

#func get_utilised_resources() -> Array[CPMB_Base]:
	#match operation:
		#0:
			#match vector_type:
				#0:
					#print("returning resources for x and y")
					#return [x_in, y_in]
				#1:	
					#print("returning resources for x, y and z")
					#return [x_in, y_in, z_in]
				#3:
					#print("returning resources for x, y, z and w")
					#return [x_in, y_in, z_in, w_in]
		#1:
			#print("returning source vector")
			#return [source_vector]
	#
	#return []
